//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/// Incrementally migrates TSAttachments owned by TSMessages to v2 attachments.
public protocol IncrementalMessageTSAttachmentMigrator {

    /// - parameter ignorePastFailures: If true, will always run regardless of past failures.
    /// If false, will skip running if previous attempts failed.
    ///
    /// Supports task cancellation.
    ///
    /// - Returns
    /// True if anything was migrated, false otherwise.
    @discardableResult
    func runUntilFinished(ignorePastFailures: Bool, progress: OWSProgressSink?) async -> Bool

    // Returns true if done.
    func runNextBatch(errorLogger: (String) -> Void) async -> Bool
}

public class IncrementalMessageTSAttachmentMigratorImpl: IncrementalMessageTSAttachmentMigrator {

    private let appContext: AppContext
    private let databaseStorage: SDSDatabaseStorage
    private let remoteConfigManager: RemoteConfigManager
    private let store: IncrementalTSAttachmentMigrationStore
    private let tsAccountManager: TSAccountManager

    public init(
        appContext: AppContext,
        appReadiness: AppReadiness,
        databaseStorage: SDSDatabaseStorage,
        remoteConfigManager: RemoteConfigManager,
        store: IncrementalTSAttachmentMigrationStore,
        tsAccountManager: TSAccountManager
    ) {
        self.appContext = appContext
        self.databaseStorage = databaseStorage
        self.remoteConfigManager = remoteConfigManager
        self.store = store
        self.tsAccountManager = tsAccountManager

        appReadiness.runNowOrWhenAppDidBecomeReadyAsync { [weak self] in
            guard let self else { return }
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appDidBecomeActive),
                name: .OWSApplicationDidBecomeActive,
                object: nil
            )
            Task { await self.runInMainAppBackground() }
        }
    }

    @objc
    private func appDidBecomeActive() {
        Task { await self.runInMainAppBackground() }
    }

    public func runUntilFinished(ignorePastFailures: Bool, progress: OWSProgressSink?) async -> Bool {
        // We DO NOT check any of the feature flag or remote config break-glass-es here;
        // this is used by backups which require the migration to have finished
        // and aren't enabled outside internal builds anyway.

        if !ignorePastFailures, !store.shouldAttemptMigrationUntilFinished() {
            Logger.warn("Skipping migration because of past failed attempts")
            return false
        }

        let state = databaseStorage.read(block: store.getState(tx:))
        switch state {
        case .finished:
            return false
        case .unstarted, .started:
            Logger.info("Running until finished")
        }

        var remainingAttachmentCount: UInt64 = 0
        var progressSource: OWSProgressSource?
        if let progress {
            remainingAttachmentCount = databaseStorage.read(block: fetchRemainingTSAttachmentCount(tx:))
            progressSource = await progress.addSource(
                withLabel: "Remaining Interactions",
                unitCount: remainingAttachmentCount
            )
        }

        store.willAttemptMigrationUntilFinished()

        var batchCount = 0
        var didFinish = false
        while !didFinish {
            // Run in batches, instead of one big write transaction, so that
            // we can commit incremental progress if we are interrupted.
            didFinish = await self.runNextBatch(errorLogger: { _ in })
            batchCount += 1

            if let progressSource {
                let newCount = databaseStorage.read(block: fetchRemainingTSAttachmentCount(tx:))
                let diff = remainingAttachmentCount - newCount
                remainingAttachmentCount = newCount
                if diff > 0 {
                    progressSource.incrementCompletedUnitCount(by: diff)
                }
            }

            do {
                try Task.checkCancellation()
            } catch {
                Logger.warn("Cancelled; stopping after \(batchCount) batches")
                return true
            }
        }

        Logger.info("Ran until finished after \(batchCount) batches")
        return true
    }

    private func fetchRemainingTSAttachmentCount(tx: DBReadTransaction) -> UInt64 {
        UInt64(clamping: (try? Int64.fetchOne(
            tx.database,
            sql: "SELECT COUNT(id) FROM model_TSAttachment;"
        )) ?? 0)
    }

    private let isRunningInMainApp = AtomicBool(false, lock: .init())

    private func runInMainAppBackground() async {
        guard
            FeatureFlags.runTSAttachmentMigrationInMainAppBackground,
            appContext.isMainAppAndActive,
            isRunningInMainApp.tryToSetFlag()
        else {
            return
        }
        defer {
            isRunningInMainApp.set(false)
        }
        let state = databaseStorage.read(block: store.getState(tx:))
        switch state {
        case .unstarted:
            Logger.info("Has not started message attachment migration")
        case .started:
            Logger.info("Partial progress on message attachment migration")
        case .finished:
            Logger.info("Finished message attachment migration")
            return
        }

        // Fetch remote config for kill switch; if fetch fails use cached local config.
        let isAllowedByRemoteConfig: Bool
        if tsAccountManager.registrationStateWithMaybeSneakyTransaction.isRegistered {
            try? await remoteConfigManager.refreshIfNeeded()
            let remoteConfig = remoteConfigManager.currentConfig()
            isAllowedByRemoteConfig = remoteConfig.shouldRunTSAttachmentMigrationInMainAppBackground
        } else {
            // If we aren't registered, we can't fetch a remote config.
            // Use default true, even if we have a cached remote config value.
            // We want to try running; worst case these deregistered users fail/crash once
            // and then are prevented from crashing further by the attempt counting.
            isAllowedByRemoteConfig = true
        }
        guard isAllowedByRemoteConfig else {
            Logger.info("Disabled via remote config, stopping")
            return
        }

        if !store.shouldAttemptMigrationUntilFinished() {
            Logger.warn("Skipping background migration because of past failed attempts")
            return
        }

        let delayMs = remoteConfigManager.currentConfig().tsAttachmentMigrationBatchDelayMs

        store.willAttemptMigrationUntilFinished()

        var batchCount = 0
        var didFinish = false
        while !didFinish {
            // Add a small delay between each batch to avoid locking the db write queue.
            try? await Task.sleep(nanoseconds: delayMs * NSEC_PER_MSEC)

            guard appContext.isMainAppAndActive else {
                // If the main app goes into the background, we shouldn't be
                // grabbing the sql write lock. Stop.
                Logger.info("Stopping when backgrounding app after \(batchCount) batches")
                if batchCount == 0 {
                    // If we exit before doing a single batch, don't count it as a failure.
                    store.didEarlyExitBeforeAttemptingBatch()
                }
                return
            }

            // Only migrate one message at a time so we don't hold the write lock
            // too long while doing file i/o.
            didFinish = await self._runNextBatch(messageBatchSize: 1, errorLogger: { _ in })
            batchCount += 1
        }
        Logger.info("Finished in main app after \(batchCount) batches")
    }

    // Returns true if done.
    public func runNextBatch(errorLogger: (String) -> Void) async -> Bool {
        return await _runNextBatch(errorLogger: errorLogger)
    }

    // Returns true if done.
    private func _runNextBatch(messageBatchSize: Int = 5, errorLogger: (String) -> Void) async -> Bool {
        typealias Migrator = TSAttachmentMigration.TSMessageMigration

        let isDone = await databaseStorage.awaitableWrite { tx in
            // First we try to migrate a batch of prepared messages.
            let didMigrateBatch = Migrator.completeNextIterativeTSMessageMigrationBatch(
                batchSize: messageBatchSize,
                errorLogger: errorLogger,
                tx: tx
            )
            if didMigrateBatch {
                return false
            }

            // If no messages are prepared, we try to prepare a batch of messages.
            let didPrepareBatch = Migrator.prepareNextIterativeTSMessageMigrationBatch(
                tx: tx
            )
            if didPrepareBatch {
                do {
                    try self.store.setState(.started, tx: tx)
                } catch let error {
                    errorLogger("\(error)")
                    owsFail("Failed to write state to db")
                }
                return false
            }

            // If there was nothing to migrate and nothing to prepare, wipe the files and finish.
            Migrator.cleanUpTSAttachmentFiles()
            do {
                try self.store.setState(.finished, tx: tx)
            } catch let error {
                errorLogger("\(error)")
                owsFail("Failed to write state to db")
            }
            return true
        }
        store.didSucceedMigrationBatch()
        return isDone
    }
}

public class NoOpIncrementalMessageTSAttachmentMigrator: IncrementalMessageTSAttachmentMigrator {
    public init() {}

    public func runUntilFinished(ignorePastFailures: Bool, progress: OWSProgressSink?) async -> Bool {
        return false
    }

    // Returns true if done.
    public func runNextBatch(errorLogger: (String) -> Void) async -> Bool {
        return true
    }
}

#if TESTABLE_BUILD

public class IncrementalMessageTSAttachmentMigratorMock: IncrementalMessageTSAttachmentMigrator {

    public init() {}

    public func runUntilFinished(ignorePastFailures: Bool, progress: OWSProgressSink?) async -> Bool {
        return false
    }

    // Returns true if done.
    public func runNextBatch(errorLogger: (String) -> Void) async -> Bool {
        return true
    }
}

#endif
