//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Contacts
import Foundation
import LibSignalClient
public import SignalServiceKit

extension RegistrationCoordinatorImpl {

    public enum Shims {
        public typealias ContactsManager = _RegistrationCoordinator_ContactsManagerShim
        public typealias ContactsStore = _RegistrationCoordinator_CNContactsStoreShim
        public typealias ExperienceManager = _RegistrationCoordinator_ExperienceManagerShim
        public typealias FeatureFlags = _RegistrationCoordinator_FeatureFlagsShim
        public typealias MessagePipelineSupervisor = _RegistrationCoordinator_MessagePipelineSupervisorShim
        public typealias MessageProcessor = _RegistrationCoordinator_MessageProcessorShim
        public typealias OWS2FAManager = _RegistrationCoordinator_OWS2FAManagerShim
        public typealias PreKeyManager = _RegistrationCoordinator_PreKeyManagerShim
        public typealias ProfileManager = _RegistrationCoordinator_ProfileManagerShim
        public typealias PushRegistrationManager = _RegistrationCoordinator_PushRegistrationManagerShim
        public typealias ReceiptManager = _RegistrationCoordinator_ReceiptManagerShim
        public typealias StorageServiceManager = _RegistrationCoordinator_StorageServiceManagerShim
        public typealias UDManager = _RegistrationCoordinator_UDManagerShim
    }
    public enum Wrappers {
        public typealias ContactsManager = _RegistrationCoordinator_ContactsManagerWrapper
        public typealias ContactsStore = _RegistrationCoordinator_CNContactsStoreWrapper
        public typealias ExperienceManager = _RegistrationCoordinator_ExperienceManagerWrapper
        public typealias FeatureFlags = _RegistrationCoordinator_FeatureFlagsWrapper
        public typealias MessagePipelineSupervisor = _RegistrationCoordinator_MessagePipelineSupervisorWrapper
        public typealias MessageProcessor = _RegistrationCoordinator_MessageProcessorWrapper
        public typealias OWS2FAManager = _RegistrationCoordinator_OWS2FAManagerWrapper
        public typealias PreKeyManager = _RegistrationCoordinator_PreKeyManagerWrapper
        public typealias ProfileManager = _RegistrationCoordinator_ProfileManagerWrapper
        public typealias PushRegistrationManager = _RegistrationCoordinator_PushRegistrationManagerWrapper
        public typealias ReceiptManager = _RegistrationCoordinator_ReceiptManagerWrapper
        public typealias StorageServiceManager = _RegistrationCoordinator_StorageServiceManagerWrapper
        public typealias UDManager = _RegistrationCoordinator_UDManagerWrapper
    }
}

// MARK: OWSContactsManager

public protocol _RegistrationCoordinator_ContactsManagerShim {

    func fetchSystemContactsOnceIfAlreadyAuthorized()
}

public class _RegistrationCoordinator_ContactsManagerWrapper: _RegistrationCoordinator_ContactsManagerShim {

    private let manager: OWSContactsManager
    public init(_ manager: OWSContactsManager) { self.manager = manager }

    public func fetchSystemContactsOnceIfAlreadyAuthorized() {
        manager.fetchSystemContactsOnceIfAlreadyAuthorized()
    }
}

// MARK: CNContacts

public protocol _RegistrationCoordinator_CNContactsStoreShim {

    func needsContactsAuthorization() -> Guarantee<Bool>

    func requestContactsAuthorization() -> Guarantee<Void>
}

public class _RegistrationCoordinator_CNContactsStoreWrapper: _RegistrationCoordinator_CNContactsStoreShim {

    public init() {}

    public func needsContactsAuthorization() -> Guarantee<Bool> {
        return .value(CNContactStore.authorizationStatus(for: .contacts) == .notDetermined)
    }

    public func requestContactsAuthorization() -> Guarantee<Void> {
        let (guarantee, future) = Guarantee<Void>.pending()
        CNContactStore().requestAccess(for: CNEntityType.contacts) { (granted, error) -> Void in
            if granted {
                Logger.info("User granted contacts permission")
            } else {
                // Unfortunately, we can't easily disambiguate "not granted" and
                // "other error".
                Logger.warn("User denied contacts permission or there was an error. Error: \(String(describing: error))")
            }
            future.resolve()
        }
        return guarantee
    }
}

// MARK: - ExperienceManager

public protocol _RegistrationCoordinator_ExperienceManagerShim {

    func clearIntroducingPinsExperience(_ tx: DBWriteTransaction)

    func enableAllGetStartedCards(_ tx: DBWriteTransaction)
}

public class _RegistrationCoordinator_ExperienceManagerWrapper: _RegistrationCoordinator_ExperienceManagerShim {

    public init() {}

    public func clearIntroducingPinsExperience(_ tx: DBWriteTransaction) {
        ExperienceUpgradeManager.clearExperienceUpgrade(.introducingPins, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func enableAllGetStartedCards(_ tx: DBWriteTransaction) {
        GetStartedBannerViewController.enableAllCards(writeTx: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - FeatureFlags

public protocol _RegistrationCoordinator_FeatureFlagsShim {

    var enableAccountEntropyPool: Bool { get }

    var messageBackupFileAlphaRegistrationFlow: Bool { get }
}

public class _RegistrationCoordinator_FeatureFlagsWrapper: _RegistrationCoordinator_FeatureFlagsShim {

    public init() {}

    public var enableAccountEntropyPool: Bool { FeatureFlags.enableAccountEntropyPool }

    public var messageBackupFileAlphaRegistrationFlow: Bool { FeatureFlags.MessageBackup.fileAlphaRegistrationFlow }
}

// MARK: - MessagePipelineSupervisor

public protocol _RegistrationCoordinator_MessagePipelineSupervisorShim {

    func suspendMessageProcessingWithoutHandle(for: MessagePipelineSupervisor.Suspension)

    func unsuspendMessageProcessing(for: MessagePipelineSupervisor.Suspension)
}

public class _RegistrationCoordinator_MessagePipelineSupervisorWrapper: _RegistrationCoordinator_MessagePipelineSupervisorShim {

    private let supervisor: MessagePipelineSupervisor

    public init(_ supervisor: MessagePipelineSupervisor) {
        self.supervisor = supervisor
    }

    public func suspendMessageProcessingWithoutHandle(for suspension: MessagePipelineSupervisor.Suspension) {
        supervisor.suspendMessageProcessingWithoutHandle(for: suspension)
    }

    public func unsuspendMessageProcessing(for suspension: MessagePipelineSupervisor.Suspension) {
        supervisor.unsuspendMessageProcessing(for: suspension)
    }
}

// MARK: - MessageProcessor

public protocol _RegistrationCoordinator_MessageProcessorShim {
    func waitForFetchingAndProcessing() -> Guarantee<Void>
}

public class _RegistrationCoordinator_MessageProcessorWrapper: _RegistrationCoordinator_MessageProcessorShim {

    private let processor: MessageProcessor

    public init(_ processor: MessageProcessor) {
        self.processor = processor
    }

    public func waitForFetchingAndProcessing() -> Guarantee<Void> {
        return processor.waitForFetchingAndProcessing()
    }
}

// MARK: - OWS2FAManager

public protocol _RegistrationCoordinator_OWS2FAManagerShim {

    func pinCode(_ tx: DBReadTransaction) -> String?

    func clearLocalPinCode(_ tx: DBWriteTransaction)

    func isReglockEnabled(_ tx: DBReadTransaction) -> Bool

    func markPinEnabled(_ pin: String, _ tx: DBWriteTransaction)

    func markRegistrationLockEnabled(_  tx: DBWriteTransaction)
}

public class _RegistrationCoordinator_OWS2FAManagerWrapper: _RegistrationCoordinator_OWS2FAManagerShim {

    private let manager: OWS2FAManager
    public init(_ manager: OWS2FAManager) { self.manager = manager }

    public func pinCode(_ tx: DBReadTransaction) -> String? {
        return manager.pinCode(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func clearLocalPinCode(_ tx: DBWriteTransaction) {
        return manager.clearLocalPinCode(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func isReglockEnabled(_ tx: DBReadTransaction) -> Bool {
        return manager.isRegistrationLockV2Enabled(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func markPinEnabled(_ pin: String, _ tx: DBWriteTransaction) {
        manager.markEnabled(pin: pin, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func markRegistrationLockEnabled(_ tx: DBWriteTransaction) {
        manager.markRegistrationLockV2Enabled(transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - PreKeyManager

// Unfortunately this shim needs to exist because of tests; Promise.wrapAsync starts a Task,
// which is unavoidably asynchronous, which does not play nice with TestScheduler and general
// synchronous, single-threaded test setups. To avoid this, we need to push down the
// Promise.wrapAsync call into the shim, so that we can avoid the call entirely in tests.
public protocol _RegistrationCoordinator_PreKeyManagerShim {

    func createPreKeysForRegistration() -> Promise<RegistrationPreKeyUploadBundles>

    func finalizeRegistrationPreKeys(
        _ prekeyBundles: RegistrationPreKeyUploadBundles,
        uploadDidSucceed: Bool
    ) -> Promise<Void>

    func rotateOneTimePreKeysForRegistration(auth: ChatServiceAuth) -> Promise<Void>
}

public class _RegistrationCoordinator_PreKeyManagerWrapper: _RegistrationCoordinator_PreKeyManagerShim {

    private let preKeyManager: PreKeyManager

    public init(_ preKeyManager: PreKeyManager) {
        self.preKeyManager = preKeyManager
    }

    public func createPreKeysForRegistration() -> Promise<RegistrationPreKeyUploadBundles> {
        let preKeyManager = self.preKeyManager
        return Promise.wrapAsync {
            return try await preKeyManager.createPreKeysForRegistration().value
        }
    }

    public func finalizeRegistrationPreKeys(
        _ prekeyBundles: RegistrationPreKeyUploadBundles,
        uploadDidSucceed: Bool
    ) -> Promise<Void> {
        let preKeyManager = self.preKeyManager
        return Promise.wrapAsync {
            return try await preKeyManager.finalizeRegistrationPreKeys(
                prekeyBundles,
                uploadDidSucceed: uploadDidSucceed
            ).value
        }
    }

    public func rotateOneTimePreKeysForRegistration(auth: ChatServiceAuth) -> Promise<Void> {
        let preKeyManager = self.preKeyManager
        return Promise.wrapAsync {
            return try await preKeyManager.rotateOneTimePreKeysForRegistration(auth: auth).value
        }
    }
}

// MARK: - ProfileManager

public protocol _RegistrationCoordinator_ProfileManagerShim {

    func localUserProfile(tx: DBReadTransaction) -> OWSUserProfile?

    // NOTE: non-optional because OWSProfileManager generates a random key
    // if one doesn't already exist.

    func updateLocalProfile(
        givenName: OWSUserProfile.NameComponent,
        familyName: OWSUserProfile.NameComponent?,
        avatarData: Data?,
        authedAccount: AuthedAccount,
        tx: DBWriteTransaction
    ) -> Promise<Void>

    func scheduleReuploadLocalProfile(authedAccount: AuthedAccount)
}

public class _RegistrationCoordinator_ProfileManagerWrapper: _RegistrationCoordinator_ProfileManagerShim {

    private let manager: ProfileManager
    public init(_ manager: ProfileManager) { self.manager = manager }

    public func localUserProfile(tx: DBReadTransaction) -> OWSUserProfile? {
        return manager.localUserProfile(tx: SDSDB.shimOnlyBridge(tx))
    }

    public func updateLocalProfile(
        givenName: OWSUserProfile.NameComponent,
        familyName: OWSUserProfile.NameComponent?,
        avatarData: Data?,
        authedAccount: AuthedAccount,
        tx: DBWriteTransaction
    ) -> Promise<Void> {
        return manager.updateLocalProfile(
            profileGivenName: .setTo(givenName),
            profileFamilyName: .setTo(familyName),
            profileBio: .setTo(nil),
            profileBioEmoji: .setTo(nil),
            profileAvatarData: .setTo(avatarData),
            visibleBadgeIds: .setTo([]),
            unsavedRotatedProfileKey: nil,
            userProfileWriter: .registration,
            authedAccount: authedAccount,
            tx: SDSDB.shimOnlyBridge(tx)
        )
    }

    public func scheduleReuploadLocalProfile(authedAccount: AuthedAccount) {
        Task {
            await DependenciesBridge.shared.db.awaitableWrite { tx in
                _ = manager.reuploadLocalProfile(
                    unsavedRotatedProfileKey: nil,
                    mustReuploadAvatar: false,
                    authedAccount: authedAccount,
                    tx: tx
                )
            }
        }
    }
}

// MARK: - PushRegistrationManager

extension Registration {
    public enum RequestPushTokensResult {
        case success(RegistrationRequestFactory.ApnRegistrationId)
        case pushUnsupported(description: String)
        case timeout
        case genericError(Error)
    }

    public enum SyncPushTokensResult {
        case success
        case pushUnsupported(description: String)
        case networkError
        case genericError(Error)
    }
}

public protocol _RegistrationCoordinator_PushRegistrationManagerShim {

    func needsNotificationAuthorization() -> Guarantee<Bool>

    func registerUserNotificationSettings() -> Guarantee<Void>

    func requestPushToken() -> Guarantee<Registration.RequestPushTokensResult>

    func receivePreAuthChallengeToken() -> Guarantee<String>

    func clearPreAuthChallengeToken()
}

public class _RegistrationCoordinator_PushRegistrationManagerWrapper: _RegistrationCoordinator_PushRegistrationManagerShim {

    private let manager: PushRegistrationManager
    public init(_ manager: PushRegistrationManager) { self.manager = manager }

    public func needsNotificationAuthorization() -> Guarantee<Bool> {
        return manager.needsNotificationAuthorization()
    }

    public func registerUserNotificationSettings() -> Guarantee<Void> {
        return Guarantee.wrapAsync { [manager] in
            await manager.registerUserNotificationSettings()
        }
    }

    public func requestPushToken() -> Guarantee<Registration.RequestPushTokensResult> {
        return manager.requestPushTokens(forceRotation: false, timeOutEventually: true)
            .map(on: SyncScheduler()) { .success($0) }
            .recover(on: SyncScheduler()) { error in
                switch error {
                case PushRegistrationError.pushNotSupported(let description):
                    return .value(.pushUnsupported(description: description))
                case PushRegistrationError.timeout:
                    return .value(.timeout)
                default:
                    return .value(.genericError(error))
                }
            }
    }

    public func receivePreAuthChallengeToken() -> Guarantee<String> {
        return manager.receivePreAuthChallengeToken()
    }

    public func clearPreAuthChallengeToken() {
        manager.clearPreAuthChallengeToken()
    }
}

// MARK: - ReceiptManager

public protocol _RegistrationCoordinator_ReceiptManagerShim {

    func setAreReadReceiptsEnabled(_ areEnabled: Bool, _ tx: DBWriteTransaction)
    func setAreStoryViewedReceiptsEnabled(_ areEnabled: Bool, _ tx: DBWriteTransaction)
}

public class _RegistrationCoordinator_ReceiptManagerWrapper: _RegistrationCoordinator_ReceiptManagerShim {

    private let manager: OWSReceiptManager
    public init(_ manager: OWSReceiptManager) { self.manager = manager }

    public func setAreReadReceiptsEnabled(_ areEnabled: Bool, _ tx: DBWriteTransaction) {
        manager.setAreReadReceiptsEnabled(areEnabled, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setAreStoryViewedReceiptsEnabled(_ areEnabled: Bool, _ tx: DBWriteTransaction) {
        StoryManager.setAreViewReceiptsEnabled(areEnabled, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - StorageService
public protocol _RegistrationCoordinator_StorageServiceManagerShim {
    func rotateManifest(mode: StorageServiceManagerManifestRotationMode, authedDevice: AuthedDevice) -> Promise<Void>
    func restoreOrCreateManifestIfNecessary(authedDevice: AuthedDevice, masterKeySource: StorageService.MasterKeySource) -> Promise<Void>
    func backupPendingChanges(authedDevice: AuthedDevice)
    func recordPendingLocalAccountUpdates()
}

public class _RegistrationCoordinator_StorageServiceManagerWrapper: _RegistrationCoordinator_StorageServiceManagerShim {
    private let manager: StorageServiceManager
    public init(_ manager: StorageServiceManager) { self.manager = manager }

    public func rotateManifest(
        mode: StorageServiceManagerManifestRotationMode,
        authedDevice: AuthedDevice
    ) -> Promise<Void> {
        Promise.wrapAsync {
            try await self.manager.rotateManifest(mode: mode, authedDevice: authedDevice)
        }
    }

    public func restoreOrCreateManifestIfNecessary(
        authedDevice: AuthedDevice,
        masterKeySource: StorageService.MasterKeySource
    ) -> Promise<Void> {
        manager.restoreOrCreateManifestIfNecessary(authedDevice: authedDevice, masterKeySource: masterKeySource)
    }

    public func backupPendingChanges(authedDevice: AuthedDevice) {
        manager.backupPendingChanges(authedDevice: authedDevice)
    }

    public func recordPendingLocalAccountUpdates() {
        manager.recordPendingLocalAccountUpdates()
    }
}

// MARK: - UDManager

public protocol _RegistrationCoordinator_UDManagerShim {

    func shouldAllowUnrestrictedAccessLocal(transaction: DBReadTransaction) -> Bool
}

public class _RegistrationCoordinator_UDManagerWrapper: _RegistrationCoordinator_UDManagerShim {

    private let manager: OWSUDManager
    public init(_ manager: OWSUDManager) { self.manager = manager }

    public func shouldAllowUnrestrictedAccessLocal(transaction: DBReadTransaction) -> Bool {
        return manager.shouldAllowUnrestrictedAccessLocal(transaction: SDSDB.shimOnlyBridge(transaction))
    }
}
