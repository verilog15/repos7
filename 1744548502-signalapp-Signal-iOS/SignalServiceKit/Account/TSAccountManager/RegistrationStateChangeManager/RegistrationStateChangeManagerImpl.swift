//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

public class RegistrationStateChangeManagerImpl: RegistrationStateChangeManager {

    public typealias TSAccountManager = SignalServiceKit.TSAccountManager & LocalIdentifiersSetter

    private let appContext: AppContext
    private let authCredentialStore: AuthCredentialStore
    private let groupsV2: GroupsV2
    private let identityManager: OWSIdentityManager
    private let notificationPresenter: any NotificationPresenter
    private let paymentsEvents: Shims.PaymentsEvents
    private let recipientManager: any SignalRecipientManager
    private let recipientMerger: RecipientMerger
    private let schedulers: Schedulers
    private let senderKeyStore: Shims.SenderKeyStore
    private let signalProtocolStoreManager: SignalProtocolStoreManager
    private let signalService: OWSSignalServiceProtocol
    private let storageServiceManager: StorageServiceManager
    private let tsAccountManager: TSAccountManager
    private let udManager: OWSUDManager
    private let versionedProfiles: VersionedProfiles

    init(
        appContext: AppContext,
        authCredentialStore: AuthCredentialStore,
        groupsV2: GroupsV2,
        identityManager: OWSIdentityManager,
        notificationPresenter: any NotificationPresenter,
        paymentsEvents: Shims.PaymentsEvents,
        recipientManager: any SignalRecipientManager,
        recipientMerger: RecipientMerger,
        schedulers: Schedulers,
        senderKeyStore: Shims.SenderKeyStore,
        signalProtocolStoreManager: SignalProtocolStoreManager,
        signalService: OWSSignalServiceProtocol,
        storageServiceManager: StorageServiceManager,
        tsAccountManager: TSAccountManager,
        udManager: OWSUDManager,
        versionedProfiles: VersionedProfiles
    ) {
        self.appContext = appContext
        self.authCredentialStore = authCredentialStore
        self.groupsV2 = groupsV2
        self.identityManager = identityManager
        self.notificationPresenter = notificationPresenter
        self.paymentsEvents = paymentsEvents
        self.recipientManager = recipientManager
        self.recipientMerger = recipientMerger
        self.schedulers = schedulers
        self.senderKeyStore = senderKeyStore
        self.signalProtocolStoreManager = signalProtocolStoreManager
        self.signalService = signalService
        self.storageServiceManager = storageServiceManager
        self.tsAccountManager = tsAccountManager
        self.udManager = udManager
        self.versionedProfiles = versionedProfiles
    }

    public func registrationState(tx: DBReadTransaction) -> TSRegistrationState {
        return tsAccountManager.registrationState(tx: tx)
    }

    public func didRegisterPrimary(
        e164: E164,
        aci: Aci,
        pni: Pni,
        authToken: String,
        tx: DBWriteTransaction
    ) {
        tsAccountManager.initializeLocalIdentifiers(
            e164: e164,
            aci: aci,
            pni: pni,
            deviceId: .primary,
            serverAuthToken: authToken,
            tx: tx
        )

        didUpdateLocalIdentifiers(e164: e164, aci: aci, pni: pni, tx: tx)

        tx.addSyncCompletion {
            self.postLocalNumberDidChangeNotification()
            self.postRegistrationStateDidChangeNotification()
        }
    }

    public func didProvisionSecondary(
        e164: E164,
        aci: Aci,
        pni: Pni,
        authToken: String,
        deviceId: DeviceId,
        tx: DBWriteTransaction
    ) {
        tsAccountManager.initializeLocalIdentifiers(
            e164: e164,
            aci: aci,
            pni: pni,
            deviceId: deviceId,
            serverAuthToken: authToken,
            tx: tx
        )
        didUpdateLocalIdentifiers(e164: e164, aci: aci, pni: pni, tx: tx)

        tx.addSyncCompletion {
            self.postLocalNumberDidChangeNotification()
            self.postRegistrationStateDidChangeNotification()
        }
    }

    public func didUpdateLocalPhoneNumber(
        _ e164: E164,
        aci: Aci,
        pni: Pni,
        tx: DBWriteTransaction
    ) {
        tsAccountManager.changeLocalNumber(newE164: e164, aci: aci, pni: pni, tx: tx)

        didUpdateLocalIdentifiers(e164: e164, aci: aci, pni: pni, tx: tx)

        tx.addSyncCompletion {
            self.postLocalNumberDidChangeNotification()
        }
    }

    public func setIsDeregisteredOrDelinked(_ isDeregisteredOrDelinked: Bool, tx: DBWriteTransaction) {
        let didChange = tsAccountManager.setIsDeregisteredOrDelinked(isDeregisteredOrDelinked, tx: tx)
        guard didChange else {
            return
        }
        Logger.warn("Updating isDeregisteredOrDelinked \(isDeregisteredOrDelinked)")

        if isDeregisteredOrDelinked {
            notificationPresenter.notifyUserOfDeregistration(tx: tx)
        }
        postRegistrationStateDidChangeNotification()
    }

    public func resetForReregistration(
        localPhoneNumber: E164,
        localAci: Aci,
        wasPrimaryDevice: Bool,
        tx: DBWriteTransaction
    ) {
        tsAccountManager.resetForReregistration(
            localNumber: localPhoneNumber,
            localAci: localAci,
            wasPrimaryDevice: wasPrimaryDevice,
            tx: tx
        )

        signalProtocolStoreManager.signalProtocolStore(for: .aci).sessionStore.resetSessionStore(tx: tx)
        signalProtocolStoreManager.signalProtocolStore(for: .pni).sessionStore.resetSessionStore(tx: tx)
        senderKeyStore.resetSenderKeyStore(tx: tx)
        udManager.removeSenderCertificates(tx: tx)
        versionedProfiles.clearProfileKeyCredentials(tx: tx)
        authCredentialStore.removeAllGroupAuthCredentials(tx: tx)
        authCredentialStore.removeAllCallLinkAuthCredentials(tx: tx)

        if wasPrimaryDevice {
            // Don't reset payments state at this time.
        } else {
            // PaymentsEvents will dispatch this event to the appropriate singletons.
            paymentsEvents.clearState(tx: tx)
        }

        tx.addSyncCompletion {
            self.postRegistrationStateDidChangeNotification()
            self.postLocalNumberDidChangeNotification()
        }
    }

    public func setIsTransferInProgress(tx: DBWriteTransaction) {
        guard tsAccountManager.setIsTransferInProgress(true, tx: tx) else {
            return
        }
        tx.addSyncCompletion {
            self.postRegistrationStateDidChangeNotification()
        }
    }

    public func setIsTransferComplete(
        sendStateUpdateNotification: Bool,
        tx: DBWriteTransaction
    ) {
        guard tsAccountManager.setIsTransferInProgress(false, tx: tx) else {
            return
        }
        if sendStateUpdateNotification {
            tx.addSyncCompletion {
                self.postRegistrationStateDidChangeNotification()
            }
        }
    }

    public func setWasTransferred(tx: DBWriteTransaction) {
        guard tsAccountManager.setWasTransferred(true, tx: tx) else {
            return
        }
        tx.addSyncCompletion {
            self.postRegistrationStateDidChangeNotification()
        }
    }

    public func cleanUpTransferStateOnAppLaunchIfNeeded() {
        tsAccountManager.cleanUpTransferStateOnAppLaunchIfNeeded()
    }

    public func unregisterFromService(auth: ChatServiceAuth) async throws {
        owsAssertBeta(appContext.isMainAppAndActive)
        let request = OWSRequestFactory.unregisterAccountRequest()
        request.auth = .identified(auth)
        do {
            try await signalService.urlSessionForMainSignalService()
                .promiseForTSRequest(request)
                .asVoid(on: schedulers.sync)
                .awaitable()

            // No need to set any state, as we wipe the whole app anyway.
            await appContext.resetAppDataAndExit()
        } catch {
            owsFailDebugUnlessNetworkFailure(error)
            throw error
        }
    }

    // MARK: - Helpers

    private func didUpdateLocalIdentifiers(
        e164: E164,
        aci: Aci,
        pni: Pni,
        tx: DBWriteTransaction
    ) {
        udManager.removeSenderCertificates(tx: tx)
        identityManager.clearShouldSharePhoneNumberForEveryone(tx: tx)
        versionedProfiles.clearProfileKeyCredentials(tx: tx)
        authCredentialStore.removeAllGroupAuthCredentials(tx: tx)
        authCredentialStore.removeAllCallLinkAuthCredentials(tx: tx)

        storageServiceManager.setLocalIdentifiers(LocalIdentifiers(aci: aci, pni: pni, e164: e164))

        let recipient = recipientMerger.applyMergeForLocalAccount(
            aci: aci,
            phoneNumber: e164,
            pni: pni,
            tx: tx
        )
        // At this stage, the device IDs on the self-recipient are irrelevant (and we always
        // append the primary device id anyway), just use the primary regardless of the local device id.
        recipientManager.markAsRegisteredAndSave(recipient, shouldUpdateStorageService: false, tx: tx)
    }

    // MARK: Notifications

    private func postRegistrationStateDidChangeNotification() {
        NotificationCenter.default.postOnMainThread(
            name: .registrationStateDidChange,
            object: nil
        )
    }

    private func postLocalNumberDidChangeNotification() {
        NotificationCenter.default.postOnMainThread(
            name: .localNumberDidChange,
            object: nil
        )
    }
}

// MARK: - Shims

extension RegistrationStateChangeManagerImpl {
    public enum Shims {
        public typealias PaymentsEvents = _RegistrationStateChangeManagerImpl_PaymentsEventsShim
        public typealias SenderKeyStore = _RegistrationStateChangeManagerImpl_SenderKeyStoreShim
    }

    public enum Wrappers {
        public typealias PaymentsEvents = _RegistrationStateChangeManagerImpl_PaymentsEventsWrapper
        public typealias SenderKeyStore = _RegistrationStateChangeManagerImpl_SenderKeyStoreWrapper
    }
}

// MARK: PaymentsEvents

public protocol _RegistrationStateChangeManagerImpl_PaymentsEventsShim {

    func clearState(tx: DBWriteTransaction)
}

public class _RegistrationStateChangeManagerImpl_PaymentsEventsWrapper: _RegistrationStateChangeManagerImpl_PaymentsEventsShim {

    private let paymentsEvents: PaymentsEvents

    public init(_ paymentsEvents: PaymentsEvents) {
        self.paymentsEvents = paymentsEvents
    }

    public func clearState(tx: DBWriteTransaction) {
        paymentsEvents.clearState(transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: SenderKeyStore

public protocol _RegistrationStateChangeManagerImpl_SenderKeyStoreShim {

    func resetSenderKeyStore(tx: DBWriteTransaction)
}

public class _RegistrationStateChangeManagerImpl_SenderKeyStoreWrapper: _RegistrationStateChangeManagerImpl_SenderKeyStoreShim {

    private let senderKeyStore: SenderKeyStore

    public init(_ senderKeyStore: SenderKeyStore) {
        self.senderKeyStore = senderKeyStore
    }

    public func resetSenderKeyStore(tx: DBWriteTransaction) {
        senderKeyStore.resetSenderKeyStore(transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - Unit Tests

#if TESTABLE_BUILD

extension RegistrationStateChangeManagerImpl {

    public func registerForTests(
        localIdentifiers: LocalIdentifiers,
        tx: DBWriteTransaction
    ) {
        owsAssertDebug(CurrentAppContext().isRunningTests)

        tsAccountManager.initializeLocalIdentifiers(
            e164: E164(localIdentifiers.phoneNumber)!,
            aci: localIdentifiers.aci,
            pni: localIdentifiers.pni!,
            deviceId: .primary,
            serverAuthToken: "",
            tx: tx
        )
        didUpdateLocalIdentifiers(
            e164: E164(localIdentifiers.phoneNumber)!,
            aci: localIdentifiers.aci,
            pni: localIdentifiers.pni!,
            tx: tx
        )
    }
}

#endif
