//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

private class LocalUserLeaveGroupJobRunnerFactory: JobRunnerFactory {
    func buildRunner() -> LocalUserLeaveGroupJobRunner { buildRunner(future: nil) }

    func buildRunner(future: Future<Void>?) -> LocalUserLeaveGroupJobRunner {
        return LocalUserLeaveGroupJobRunner(future: future)
    }
}

private class LocalUserLeaveGroupJobRunner: JobRunner {
    private enum Constants {
        static let maxRetries: UInt = 110
    }

    private let future: Future<Void>?

    init(future: Future<Void>?) {
        self.future = future
    }

    func runJobAttempt(_ jobRecord: LocalUserLeaveGroupJobRecord) async -> JobAttemptResult {
        return await JobAttemptResult.executeBlockWithDefaultErrorHandler(
            jobRecord: jobRecord,
            retryLimit: Constants.maxRetries,
            db: DependenciesBridge.shared.db,
            block: { try await _runJobAttempt(jobRecord) }
        )
    }

    func didFinishJob(_ jobRecordId: JobRecord.RowId, result: JobResult) async {
        switch result.ranSuccessfullyOrError {
        case .success:
            future?.resolve()
        case .failure(let error):
            future?.reject(error)
        }
    }

    private func _runJobAttempt(_ jobRecord: LocalUserLeaveGroupJobRecord) async throws {
        if jobRecord.waitForMessageProcessing {
            try await GroupManager.waitForMessageFetchingAndProcessingWithTimeout(description: #fileID)
        }

        let groupModel = try SSKEnvironment.shared.databaseStorageRef.read { tx in
            try fetchGroupModel(threadUniqueId: jobRecord.threadId, tx: tx)
        }

        let replacementAdminAci: Aci? = try jobRecord.replacementAdminAciString.map { aciString in
            guard let aci = Aci.parseFrom(aciString: aciString) else {
                throw OWSAssertionError("Couldn't parse replacementAdminAci")
            }
            return aci
        }

        try await GroupManager.updateGroupV2(
            groupModel: groupModel,
            description: #fileID
        ) { groupChangeSet in
            groupChangeSet.setShouldLeaveGroupDeclineInvite()

            // Sometimes when we leave a group we take care to assign a new admin.
            if let replacementAdminAci {
                groupChangeSet.changeRoleForMember(replacementAdminAci, role: .administrator)
            }
        }

        await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { tx in
            jobRecord.anyRemove(transaction: tx)
        }
    }

    private func fetchGroupModel(threadUniqueId: String, tx: DBReadTransaction) throws -> TSGroupModelV2 {
        guard
            let groupThread = TSGroupThread.anyFetchGroupThread(uniqueId: threadUniqueId, transaction: tx),
            let groupModel = groupThread.groupModel as? TSGroupModelV2
        else {
            throw OWSAssertionError("Missing V2 group thread for operation")
        }
        return groupModel
    }
}

public class LocalUserLeaveGroupJobQueue {
    private let jobQueueRunner: JobQueueRunner<
        JobRecordFinderImpl<LocalUserLeaveGroupJobRecord>,
        LocalUserLeaveGroupJobRunnerFactory
    >
    private var jobSerializer = CompletionSerializer()
    private let jobRunnerFactory: LocalUserLeaveGroupJobRunnerFactory

    public init(db: any DB, reachabilityManager: SSKReachabilityManager) {
        self.jobRunnerFactory = LocalUserLeaveGroupJobRunnerFactory()
        self.jobQueueRunner = JobQueueRunner(
            canExecuteJobsConcurrently: false,
            db: db,
            jobFinder: JobRecordFinderImpl(db: db),
            jobRunnerFactory: self.jobRunnerFactory
        )
        self.jobQueueRunner.listenForReachabilityChanges(reachabilityManager: reachabilityManager)
    }

    func start(appContext: AppContext) {
        jobQueueRunner.start(shouldRestartExistingJobs: appContext.isMainApp)
    }

    // MARK: - Promises

    public func addJob(
        groupThread: TSGroupThread,
        replacementAdminAci: Aci?,
        waitForMessageProcessing: Bool,
        tx: DBWriteTransaction
    ) -> Promise<Void> {
        guard groupThread.isGroupV2Thread else {
            owsFail("[GV1] Mutations on V1 groups should be impossible!")
        }
        return Promise { future in
            addJob(
                threadId: groupThread.uniqueId,
                replacementAdminAci: replacementAdminAci,
                waitForMessageProcessing: waitForMessageProcessing,
                future: future,
                tx: tx
            )
        }
    }

    private func addJob(
        threadId: String,
        replacementAdminAci: Aci?,
        waitForMessageProcessing: Bool,
        future: Future<Void>,
        tx: DBWriteTransaction
    ) {
        let jobRecord = LocalUserLeaveGroupJobRecord(
            threadId: threadId,
            replacementAdminAci: replacementAdminAci,
            waitForMessageProcessing: waitForMessageProcessing
        )
        jobRecord.anyInsert(transaction: tx)
        jobSerializer.addOrderedSyncCompletion(tx: tx) {
            self.jobQueueRunner.addPersistedJob(jobRecord, runner: self.jobRunnerFactory.buildRunner(future: future))
        }
    }
}
