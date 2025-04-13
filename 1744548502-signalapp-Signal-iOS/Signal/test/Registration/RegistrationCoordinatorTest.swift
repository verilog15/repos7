//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient
import Testing

@testable import Signal
@testable import SignalServiceKit

public class RegistrationCoordinatorTest {
    private var scheduler: TestScheduler!
    private var stubs = Stubs()

    private var date: Date { self.stubs.date }
    private var dateProvider: DateProvider!

    private var appExpiryMock: MockAppExpiry!
    private var changeNumberPniManager: ChangePhoneNumberPniManagerMock!
    private var contactsStore: RegistrationCoordinatorImpl.TestMocks.ContactsStore!
    private var db: (any DB)!
    private var experienceManager: RegistrationCoordinatorImpl.TestMocks.ExperienceManager!
    private var featureFlags: RegistrationCoordinatorImpl.TestMocks.FeatureFlags!
    private var accountKeyStore: AccountKeyStore!
    private var localUsernameManagerMock: MockLocalUsernameManager!
    private var mockMessagePipelineSupervisor: RegistrationCoordinatorImpl.TestMocks.MessagePipelineSupervisor!
    private var mockMessageProcessor: RegistrationCoordinatorImpl.TestMocks.MessageProcessor!
    private var mockURLSession: TSRequestOWSURLSessionMock!
    private var ows2FAManagerMock: RegistrationCoordinatorImpl.TestMocks.OWS2FAManager!
    private var phoneNumberDiscoverabilityManagerMock: MockPhoneNumberDiscoverabilityManager!
    private var preKeyManagerMock: RegistrationCoordinatorImpl.TestMocks.PreKeyManager!
    private var profileManagerMock: RegistrationCoordinatorImpl.TestMocks.ProfileManager!
    private var pushRegistrationManagerMock: RegistrationCoordinatorImpl.TestMocks.PushRegistrationManager!
    private var receiptManagerMock: RegistrationCoordinatorImpl.TestMocks.ReceiptManager!
    private var registrationCoordinatorLoader: RegistrationCoordinatorLoaderImpl!
    private var registrationStateChangeManagerMock: MockRegistrationStateChangeManager!
    private var sessionManager: RegistrationSessionManagerMock!
    private var storageServiceManagerMock: RegistrationCoordinatorImpl.TestMocks.StorageServiceManager!
    private var svr: SecureValueRecoveryMock!
    private var svrLocalStorageMock: SVRLocalStorageMock!
    private var svrAuthCredentialStore: SVRAuthCredentialStorageMock!
    private var tsAccountManagerMock: MockTSAccountManager!
    private var usernameApiClientMock: MockUsernameApiClient!
    private var usernameLinkManagerMock: MockUsernameLinkManager!
    private var missingKeyGenerator: MissingKeyGenerator!

    private class MissingKeyGenerator {
        var masterKey: () -> MasterKey = { fatalError("Default MasterKey not provided") }
        var accountEntropyPool: () -> SignalServiceKit.AccountEntropyPool = { fatalError("Default AccountEntropyPool not provided")  }
    }

    init() {
        dateProvider = { self.date }
        db = InMemoryDB()

        missingKeyGenerator = .init()

        appExpiryMock = MockAppExpiry()
        changeNumberPniManager = ChangePhoneNumberPniManagerMock(
            mockKyberStore: MockKyberPreKeyStore(dateProvider: Date.provider)
        )
        contactsStore = RegistrationCoordinatorImpl.TestMocks.ContactsStore()
        experienceManager = RegistrationCoordinatorImpl.TestMocks.ExperienceManager()
        featureFlags = RegistrationCoordinatorImpl.TestMocks.FeatureFlags()
        accountKeyStore = AccountKeyStore(
            masterKeyGenerator: { self.missingKeyGenerator.masterKey() },
            accountEntropyPoolGenerator: { self.missingKeyGenerator.accountEntropyPool() }
        )
        localUsernameManagerMock = {
            let mock = MockLocalUsernameManager()
            // This should result in no username reclamation. Tests that want to
            // test reclamation should overwrite this.
            mock.startingUsernameState = .unset
            return mock
        }()
        svr = SecureValueRecoveryMock()
        svrAuthCredentialStore = SVRAuthCredentialStorageMock()
        mockMessagePipelineSupervisor = RegistrationCoordinatorImpl.TestMocks.MessagePipelineSupervisor()
        mockMessageProcessor = RegistrationCoordinatorImpl.TestMocks.MessageProcessor()
        ows2FAManagerMock = RegistrationCoordinatorImpl.TestMocks.OWS2FAManager()
        phoneNumberDiscoverabilityManagerMock = MockPhoneNumberDiscoverabilityManager()
        preKeyManagerMock = RegistrationCoordinatorImpl.TestMocks.PreKeyManager()
        profileManagerMock = RegistrationCoordinatorImpl.TestMocks.ProfileManager()
        pushRegistrationManagerMock = RegistrationCoordinatorImpl.TestMocks.PushRegistrationManager()
        receiptManagerMock = RegistrationCoordinatorImpl.TestMocks.ReceiptManager()
        registrationStateChangeManagerMock = MockRegistrationStateChangeManager()
        sessionManager = RegistrationSessionManagerMock()
        svrLocalStorageMock = SVRLocalStorageMock()
        storageServiceManagerMock = RegistrationCoordinatorImpl.TestMocks.StorageServiceManager()
        tsAccountManagerMock = MockTSAccountManager()
        usernameApiClientMock = MockUsernameApiClient()
        usernameLinkManagerMock = MockUsernameLinkManager()

        let mockURLSession = TSRequestOWSURLSessionMock()
        self.mockURLSession = mockURLSession
        let mockSignalService = OWSSignalServiceMock()
        mockSignalService.mockUrlSessionBuilder = { _, _, _ in
            return mockURLSession
        }

        scheduler = TestScheduler()

        let dependencies = RegistrationCoordinatorDependencies(
            appExpiry: appExpiryMock,
            changeNumberPniManager: changeNumberPniManager,
            contactsManager: RegistrationCoordinatorImpl.TestMocks.ContactsManager(),
            contactsStore: contactsStore,
            dateProvider: { self.dateProvider() },
            db: db,
            experienceManager: experienceManager,
            featureFlags: featureFlags,
            accountKeyStore: accountKeyStore,
            localUsernameManager: localUsernameManagerMock,
            messageBackupKeyMaterial: MessageBackupKeyMaterialMock(),
            messageBackupErrorPresenter: NoOpMessageBackupErrorPresenter(),
            messageBackupManager: MessageBackupManagerMock(),
            messagePipelineSupervisor: mockMessagePipelineSupervisor,
            messageProcessor: mockMessageProcessor,
            ows2FAManager: ows2FAManagerMock,
            phoneNumberDiscoverabilityManager: phoneNumberDiscoverabilityManagerMock,
            pniHelloWorldManager: PniHelloWorldManagerMock(),
            preKeyManager: preKeyManagerMock,
            profileManager: profileManagerMock,
            pushRegistrationManager: pushRegistrationManagerMock,
            receiptManager: receiptManagerMock,
            registrationStateChangeManager: registrationStateChangeManagerMock,
            schedulers: TestSchedulers(scheduler: scheduler),
            sessionManager: sessionManager,
            signalService: mockSignalService,
            storageServiceRecordIkmCapabilityStore: StorageServiceRecordIkmCapabilityStoreImpl(),
            storageServiceManager: storageServiceManagerMock,
            svr: svr,
            svrAuthCredentialStore: svrAuthCredentialStore,
            tsAccountManager: tsAccountManagerMock,
            udManager: RegistrationCoordinatorImpl.TestMocks.UDManager(),
            usernameApiClient: usernameApiClientMock,
            usernameLinkManager: usernameLinkManagerMock
        )
        registrationCoordinatorLoader = RegistrationCoordinatorLoaderImpl(dependencies: dependencies)
    }

    enum KeyType: CustomDebugStringConvertible {
        case none
        case masterKey
        case accountEntropyPool

        var debugDescription: String {
            switch self {
            case .none: return "none"
            case .masterKey: return "masterKey"
            case .accountEntropyPool: return "AEP"
            }
        }

        static var testCases: [(old: Self, new: Self)] {
            return [
                (.masterKey, .masterKey),
                (.masterKey, .accountEntropyPool),
                (.accountEntropyPool, .accountEntropyPool)
            ]
        }

        static var noKeyTestCases: [(old: Self, new: Self)] {
            return [
                (.none, .masterKey),
                (.none, .accountEntropyPool)
            ]
        }

    }

    static let testModes: [RegistrationMode] = [
        RegistrationMode.registering,
        RegistrationMode.reRegistering(.init(e164: Stubs.e164, aci: Stubs.aci))
    ]

    typealias TestCase = (mode: RegistrationMode, oldKey: KeyType, newKey: KeyType)

    static func testCases() -> [TestCase] {
        var results = [(mode: RegistrationMode, oldKey: KeyType, newKey: KeyType)]()
        for mode in Self.testModes {
            for keys in KeyType.testCases {
                results.append((mode, keys.old, keys.new))
            }
        }
        return results
    }

    func setupTest(_ testCase: TestCase) -> RegistrationCoordinatorImpl {
        featureFlags.enableAccountEntropyPool = testCase.newKey == .accountEntropyPool
        return db.write {
            return registrationCoordinatorLoader.coordinator(
                forDesiredMode: testCase.mode,
                transaction: $0
            ) as! RegistrationCoordinatorImpl
        }
    }

    enum TestStep: String, Equatable, CustomDebugStringConvertible {
        case restoreKeys
        case requestPushToken
        case createPreKeys
        case createAccount
        case finalizePreKeys
        case rotateOneTimePreKeys
        case restoreStorageService
        case backupMasterKey
        case confirmReservedUsername
        case rotateManifest
        case updateAccountAttribute
        case failedRequest

        var debugDescription: String {
            switch self {
            case .restoreKeys: return "restoreKeys"
            case .requestPushToken: return "requestPushToken"
            case .createPreKeys: return "createPreKeys"
            case .createAccount: return "createAccount"
            case .finalizePreKeys: return "finalizePreKeys"
            case .rotateOneTimePreKeys: return "rotateOneTimePreKeys"
            case .restoreStorageService: return "restoreStorageService"
            case .backupMasterKey: return "backupMasterKey"
            case .confirmReservedUsername: return "confirmReservedUsername"
            case .rotateManifest: return "rotateManifest"
            case .updateAccountAttribute: return "updateAccountAttribute"
            case .failedRequest: return "failedRequest"
            }
        }
    }

    // MARK: - Opening Path

    @MainActor
    @Test(arguments: Self.testCases())
    func testOpeningPath_splash(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Don't care about timing, just start it.
        scheduler.start()

        setupDefaultAccountAttributes()

        switch mode {
        case .registering:
            // With no state set up, should show the splash.
            #expect(coordinator.nextStep().value == .registrationSplash)
            // Once we show it, don't show it again.
            #expect(coordinator.continueFromSplash().value != .registrationSplash)
        case .reRegistering, .changingNumber:
            #expect(coordinator.nextStep().value != .registrationSplash)
        }
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testOpeningPath_appExpired(testCase: TestCase) {
        let coordinator = setupTest(testCase)

        // Don't care about timing, just start it.
        scheduler.start()

        appExpiryMock.expirationDate = .distantPast

        setupDefaultAccountAttributes()

        // We should start with the banner.
        #expect(coordinator.nextStep().value == .appUpdateBanner)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testOpeningPath_permissions(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Don't care about timing, just start it.
        scheduler.start()

        setupDefaultAccountAttributes()

        contactsStore.doesNeedContactsAuthorization = true
        pushRegistrationManagerMock.doesNeedNotificationAuthorization = true

        var nextStep: Guarantee<RegistrationStep>
        switch mode {
        case .registering:
            // Gotta get the splash out of the way.
            #expect(coordinator.nextStep().value == .registrationSplash)
            nextStep = coordinator.continueFromSplash()
        case .reRegistering, .changingNumber:
            // No splash for these.
            nextStep = coordinator.nextStep()
        }

        // Now we should show the permissions.
        #expect(nextStep.value == .permissions)
        // Doesn't change even if we try and proceed.
        #expect(coordinator.nextStep().value == .permissions)

        // Once the state is updated we can proceed.
        nextStep = coordinator.requestPermissions()
        #expect(nextStep.value != nil)
        #expect(nextStep.value != .registrationSplash)
        #expect(nextStep.value != .permissions)
    }

    // MARK: - Reg Recovery Password Path

    @MainActor
    @Test(arguments: Self.testCases(), [true, false])
    func runRegRecoverPwPathTestHappyPath(testCase: TestCase, wasReglockEnabled: Bool) throws {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Don't care about timing, just start it.
        scheduler.start()

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        ows2FAManagerMock.isReglockEnabledMock = { wasReglockEnabled }

        // Set a PIN on disk.
        ows2FAManagerMock.pinCodeMock = { Stubs.pinCode }

        let (initialMasterKey, finalMasterKey) = buildKeyDataMocks(testCase)

        // NOTE: We expect to skip opening path steps because
        // if we have a SVR master key locally, this _must_ be
        // a previously registered device, and we can skip intros.

        // We haven't set a phone number so it should ask for that.
        #expect(coordinator.nextStep().value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode)))

        // Give it a phone number, which should show the PIN entry step.
        var nextStep = coordinator.submitE164(Stubs.e164).value
        // Now it should ask for the PIN to confirm the user knows it.
        #expect(nextStep == .pinEntry(Stubs.pinEntryStateForRegRecoveryPath(mode: mode)))

        // Give it the pin code, which should make it try and register.

        // It needs an apns token to register.
        pushRegistrationManagerMock.requestPushTokenMock = {
            return .value(.success(Stubs.apnsRegistrationId))
        }
        // It needs prekeys as well.
        preKeyManagerMock.createPreKeysMock = {
            return .value(Stubs.prekeyBundles())
        }
        // And will finalize prekeys after success.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            #expect(didSucceed)
            return .value(())
        }

        let expectedRequest = RegistrationRequestFactory.createAccountRequest(
            verificationMethod: .recoveryPassword(initialMasterKey.regRecoveryPw),
            e164: Stubs.e164,
            authPassword: "", // Doesn't matter for request generation.
            accountAttributes: Stubs.accountAttributes(initialMasterKey),
            skipDeviceTransfer: true,
            apnRegistrationId: Stubs.apnsRegistrationId,
            prekeyBundles: Stubs.prekeyBundles()
        )
        let identityResponse = Stubs.accountIdentityResponse()
        var authPassword: String!
        mockURLSession.addResponse(TSRequestOWSURLSessionMock.Response(
            matcher: { request in
                // The password is generated internally by RegistrationCoordinator.
                // Extract it so we can check that the same password sent to the server
                // to register is used later for other requests.
                authPassword = request.authPassword
                let requestAttributes = Self.attributesFromCreateAccountRequest(request)
                let recoveryPw = initialMasterKey.regRecoveryPw
                #expect(recoveryPw == (request.parameters["recoveryPassword"] as? String) ?? "")
                #expect(recoveryPw == requestAttributes.registrationRecoveryPassword)
                if wasReglockEnabled {
                    #expect(initialMasterKey.reglockToken == requestAttributes.registrationLockToken)
                } else {
                    #expect(requestAttributes.registrationLockToken == nil)
                }
                return request.url == expectedRequest.url
            },
            statusCode: 200,
            bodyData: try JSONEncoder().encode(identityResponse)
        ))

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: identityResponse.aci,
                pni: identityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // When registered, we should create pre-keys.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return .value(())
        }

        if wasReglockEnabled {
            // If we had reglock before registration, it should be re-enabled.
            let expectedReglockRequest = OWSRequestFactory.enableRegistrationLockV2Request(token: finalMasterKey.reglockToken)
            mockURLSession.addResponse(TSRequestOWSURLSessionMock.Response(
                matcher: { request in
                    #expect(finalMasterKey.reglockToken == request.parameters["registrationLock"] as! String)
                    return request.url == expectedReglockRequest.url
                },
                statusCode: 200,
                bodyData: nil
            ))
        }

        // We haven't done a SVR backup; that should happen now.
        svr.backupMasterKeyMock = { pin, masterKey, authMethod in
            #expect(pin == Stubs.pinCode)
            // We don't have a SVR auth credential, it should use chat server creds.
            #expect(masterKey.rawData == finalMasterKey.rawData)
            #expect(authMethod == .chatServerAuth(expectedAuthedAccount()))
            self.svr.hasMasterKey = true
            return .value(masterKey)
        }

        // Once we sync push tokens, we should restore from storage service.
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            #expect(auth.authedAccount == expectedAuthedAccount())
            switch masterKeySource {
            case .explicit(let explicitMasterKey):
                #expect(initialMasterKey.rawData == explicitMasterKey.rawData)
            default:
                Issue.record("Unexpected master key used in storage service operation.")
            }
            return .value(())
        }

        // Once we restore from storage service, we should attempt to reclaim
        // our username.
        let mockUsernameLink: Usernames.UsernameLink = .mocked
        localUsernameManagerMock.startingUsernameState = .available(username: "boba.42", usernameLink: mockUsernameLink)
        usernameApiClientMock.confirmReservedUsernameMock = { _, _, chatServiceAuth in
            #expect(chatServiceAuth == .explicit(
                aci: identityResponse.aci,
                deviceId: .primary,
                password: authPassword
            ))
            return .value(.success(usernameLinkHandle: mockUsernameLink.handle))
        }

        // Once we do the username reclamation,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(finalMasterKey),
            auth: .implicit() // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            matcher: { request in
                return request.url == expectedAttributesRequest.url
            },
            statusCode: 200
        )

        nextStep = coordinator.submitPINCode(Stubs.pinCode).value
        #expect(nextStep == .done)

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testRegRecoveryPwPath_wrongPIN(testCase: TestCase) throws {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Don't care about timing, just start it.
        scheduler.start()

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        let wrongPinCode = "ABCD"

        // Set a different PIN on disk.
        ows2FAManagerMock.pinCodeMock = { Stubs.pinCode }

        let (initialMasterKey, finalMasterKey) = buildKeyDataMocks(testCase)
        // NOTE: We expect to skip opening path steps because
        // if we have a SVR master key locally, this _must_ be
        // a previously registered device, and we can skip intros.

        // We haven't set a phone number so it should ask for that.
        #expect(coordinator.nextStep().value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode)))

        // Give it a phone number, which should show the PIN entry step.
        var nextStep = coordinator.submitE164(Stubs.e164).value
        // Now it should ask for the PIN to confirm the user knows it.
        #expect(nextStep == .pinEntry(Stubs.pinEntryStateForRegRecoveryPath(mode: mode)))

        // Give it the wrong PIN, it should reject and give us the same step again.
        nextStep = coordinator.submitPINCode(wrongPinCode).value
        #expect(
            nextStep == .pinEntry(Stubs.pinEntryStateForRegRecoveryPath(
                mode: mode,
                error: .wrongPin(wrongPin: wrongPinCode),
                remainingAttempts: 9
            ))
        )

        // Give it the right pin code, which should make it try and register.

        // It needs an apns token to register.
        pushRegistrationManagerMock.requestPushTokenMock = {
            return .value(.success(Stubs.apnsRegistrationId))
        }
        // Every time we register we also ask for prekeys.
        preKeyManagerMock.createPreKeysMock = {
            return .value(Stubs.prekeyBundles())
        }
        // And we finalize them after.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            #expect(didSucceed)
            return .value(())
        }

        let expectedRequest = RegistrationRequestFactory.createAccountRequest(
            verificationMethod: .recoveryPassword(initialMasterKey.regRecoveryPw),
            e164: Stubs.e164,
            authPassword: "", // Doesn't matter for request generation.
            accountAttributes: Stubs.accountAttributes(initialMasterKey),
            skipDeviceTransfer: true,
            apnRegistrationId: Stubs.apnsRegistrationId,
            prekeyBundles: Stubs.prekeyBundles()
        )

        let identityResponse = Stubs.accountIdentityResponse()
        var authPassword: String!
        mockURLSession.addResponse(TSRequestOWSURLSessionMock.Response(
            matcher: { request in
                authPassword = request.authPassword
                let requestAttributes = Self.attributesFromCreateAccountRequest(request)
                let recoveryPw = initialMasterKey.regRecoveryPw
                #expect(recoveryPw == (request.parameters["recoveryPassword"] as? String) ?? "")
                #expect(recoveryPw == requestAttributes.registrationRecoveryPassword)
                #expect(requestAttributes.registrationLockToken == nil)
                return request.url == expectedRequest.url
            },
            statusCode: 200,
            bodyData: try JSONEncoder().encode(identityResponse)
        ))

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: identityResponse.aci,
                pni: identityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // When registered, we should create pre-keys.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return .value(())
        }

        // We haven't done a SVR backup; that should happen now.
        svr.backupMasterKeyMock = { pin, masterKey, authMethod in
            #expect(pin == Stubs.pinCode)
            #expect(masterKey.rawData == finalMasterKey.rawData)
            // We don't have a SVR auth credential, it should use chat server creds.
            #expect(authMethod == .chatServerAuth(expectedAuthedAccount()))
            self.svr.hasMasterKey = true
            return .value(masterKey)
        }

        // Once we sync push tokens, we should restore from storage service.
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            #expect(auth.authedAccount == expectedAuthedAccount())
            switch masterKeySource {
            case .explicit(let explicitMasterKey):
                #expect(initialMasterKey.rawData == explicitMasterKey.rawData)
            default:
                Issue.record("Unexpected master key used in storage service operation.")
            }
            return .value(())
        }

        // Once we restore from storage service, we should attempt to reclaim
        // our username. For this test, let's have a corrupted username (and
        // skip reclamation). This should have no impact on the rest of
        // registration.
        localUsernameManagerMock.startingUsernameState = .usernameAndLinkCorrupted

        // Once we do the storage service restore,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(finalMasterKey),
            auth: .implicit() // // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            matcher: { request in
                #expect(finalMasterKey.regRecoveryPw == (request.parameters["recoveryPassword"] as? String) ?? "")
                return request.url == expectedAttributesRequest.url
            },
            statusCode: 200
        )

        nextStep = coordinator.submitPINCode(Stubs.pinCode).value
        #expect(nextStep == .done)

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testRegRecoveryPwPath_wrongPassword(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        // Set a PIN on disk.
        ows2FAManagerMock.pinCodeMock = { Stubs.pinCode }

        // Make SVR give us back a reg recovery password.
        let masterKey = AccountEntropyPool().getMasterKey()
        db.write { accountKeyStore.setMasterKey(masterKey, tx: $0) }
        svr.hasMasterKey = true

        // Run the scheduler for a bit; we don't care about timing these bits.
        scheduler.start()

        // NOTE: We expect to skip opening path steps because
        // if we have a SVR master key locally, this _must_ be
        // a previously registered device, and we can skip intros.

        // We haven't set a phone number so it should ask for that.
        #expect(coordinator.nextStep().value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode)))

        // Give it a phone number, which should show the PIN entry step.
        var nextStep = coordinator.submitE164(Stubs.e164)
        // Now it should ask for the PIN to confirm the user knows it.
        #expect(nextStep.value == .pinEntry(Stubs.pinEntryStateForRegRecoveryPath(mode: mode)))

        // Now we want to control timing so we can verify things happened in the right order.
        scheduler.stop()
        scheduler.adjustTime(to: 0)

        // Give it the pin code, which should make it try and register.
        nextStep = coordinator.submitPINCode(Stubs.pinCode)

        // Before registering at t=0, it should ask for push tokens to give the registration.
        // It will also ask again later at t=3 when account creation fails and it needs
        // to create a new session.
        pushRegistrationManagerMock.requestPushTokenMock = {
            switch self.scheduler.currentTime {
            case 0:
                return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 1)
            case 3:
                return .value(.success(Stubs.apnsRegistrationId))
            default:
                Issue.record("Got unexpected push tokens request")
                return .value(.timeout)
            }
        }
        // Every time we register we also ask for prekeys.
        preKeyManagerMock.createPreKeysMock = {
            switch self.scheduler.currentTime {
            case 1, 3:
                return .value(Stubs.prekeyBundles())
            default:
                Issue.record("Got unexpected push tokens request")
                return .init(error: PreKeyError())
            }
        }
        // And we finalize them after.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            switch self.scheduler.currentTime {
            case 3:
                #expect(didSucceed.negated)
                return .value(())
            case 4:
                #expect(didSucceed)
                return .value(())
            default:
                Issue.record("Got unexpected push tokens request")
                return .init(error: PreKeyError())
            }
        }

        let expectedRecoveryPwRequest = RegistrationRequestFactory.createAccountRequest(
            verificationMethod: .recoveryPassword(masterKey.regRecoveryPw),
            e164: Stubs.e164,
            authPassword: "", // Doesn't matter for request generation.
            accountAttributes: Stubs.accountAttributes(masterKey),
            skipDeviceTransfer: true,
            apnRegistrationId: Stubs.apnsRegistrationId,
            prekeyBundles: Stubs.prekeyBundles()
        )

        // Fail the request at t=3; the reg recovery pw is invalid.
        let failResponse = TSRequestOWSURLSessionMock.Response(
            urlSuffix: expectedRecoveryPwRequest.url!.absoluteString,
            statusCode: RegistrationServiceResponses.AccountCreationResponseCodes.unauthorized.rawValue
        )
        mockURLSession.addResponse(failResponse, atTime: 3, on: scheduler)

        // Once the first request fails, at t=3, it should try an start a session.
        scheduler.run(atTime: 2) {
            // Resolve with a session at time 4.
            self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: false)),
                atTime: 4
            )
        }

        // Before requesting a session at t=3, it should ask for push tokens to give the session.
        // This was set up above.

        // Then when it gets back the session at t=4, it should immediately ask for
        // a verification code to be sent.
        scheduler.run(atTime: 4) {
            // We'll ask for a push challenge, though we don't need to resolve it in this test.
            self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
                return Guarantee<String>.pending().0
            }

            // Resolve with an updated session at time 5.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: true)),
                atTime: 5
            )
        }

        // Check we have the master key now, to be safe.
        #expect(svr.hasMasterKey)
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 5)

        // Now we should expect to be at verification code entry since we already set the phone number.
        // No exit allowed since we've already started trying to create the account.
        #expect(nextStep.value == .verificationCodeEntry(
            self.stubs.verificationCodeEntryState(mode: mode, exitConfigOverride: .noExitAllowed)
        ))
        // We want to have kept the master key; we failed the reg recovery pw check
        // but that could happen even if the key is valid. Once we finish session based
        // re-registration we want to be able to recover the key.
        #expect(svr.hasMasterKey)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testRegRecoveryPwPath_failedReglock(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        // Set a PIN on disk.
        ows2FAManagerMock.pinCodeMock = { Stubs.pinCode }

        // Make SVR give us back a reg recovery password.
        let masterKey = AccountEntropyPool().getMasterKey()
        db.write { accountKeyStore.setMasterKey(masterKey, tx: $0) }
        svr.hasMasterKey = true

        // Run the scheduler for a bit; we don't care about timing these bits.
        scheduler.start()

        // NOTE: We expect to skip opening path steps because
        // if we have a SVR master key locally, this _must_ be
        // a previously registered device, and we can skip intros.

        // We haven't set a phone number so it should ask for that.
        #expect(coordinator.nextStep().value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode)))

        // Give it a phone number, which should show the PIN entry step.
        var nextStep = coordinator.submitE164(Stubs.e164)
        // Now it should ask for the PIN to confirm the user knows it.
        #expect(nextStep.value == .pinEntry(Stubs.pinEntryStateForRegRecoveryPath(mode: mode)))

        // Now we want to control timing so we can verify things happened in the right order.
        scheduler.stop()
        scheduler.adjustTime(to: 0)

        // Give it the pin code, which should make it try and register.
        nextStep = coordinator.submitPINCode(Stubs.pinCode)

        // First we try and create an account with reg recovery
        // password; we will fail with reglock error.
        // First we get apns tokens, then prekeys, then register
        // then finalize prekeys (with failure) after.
        let firstPushTokenTime = 0
        let firstPreKeyCreateTime = 1
        let firstRegistrationTime = 2
        let firstPreKeyFinalizeTime = 3

        // Once we fail, we try again immediately with the reglock
        // token we fetch.
        // Same sequence as the first request.
        let secondPushTokenTime = 4
        let secondPreKeyCreateTime = 5
        let secondRegistrationTime = 6
        let secondPreKeyFinalizeTime = 7

        // When that fails, we try and create a session.
        // No prekey stuff this time, just apns token and session requests.
        let thirdPushTokenTime = 8
        let sessionStartTime = 9
        let sendVerificationCodeTime = 10

        pushRegistrationManagerMock.requestPushTokenMock = {
            switch self.scheduler.currentTime {
            case firstPushTokenTime, secondPushTokenTime, thirdPushTokenTime:
                return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: self.scheduler.currentTime + 1)
            default:
                Issue.record("Got unexpected push tokens request")
                return .value(.timeout)
            }
        }
        preKeyManagerMock.createPreKeysMock = {
            switch self.scheduler.currentTime {
            case firstPreKeyCreateTime, secondPreKeyCreateTime:
                return self.scheduler.promise(resolvingWith: Stubs.prekeyBundles(), atTime: self.scheduler.currentTime + 1)
            default:
                Issue.record("Got unexpected prekeys request")
                return .init(error: PreKeyError())
            }
        }
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            switch self.scheduler.currentTime {
            case firstPreKeyFinalizeTime, secondPreKeyFinalizeTime:
                #expect(didSucceed.negated)
                return self.scheduler.promise(resolvingWith: (), atTime: self.scheduler.currentTime + 1)
            default:
                Issue.record("Got unexpected prekeys request")
                return .init(error: PreKeyError())
            }
        }

        let expectedRecoveryPwRequest = RegistrationRequestFactory.createAccountRequest(
            verificationMethod: .recoveryPassword(masterKey.regRecoveryPw),
            e164: Stubs.e164,
            authPassword: "", // Doesn't matter for request generation.
            accountAttributes: Stubs.accountAttributes(masterKey),
            skipDeviceTransfer: true,
            apnRegistrationId: Stubs.apnsRegistrationId,
            prekeyBundles: Stubs.prekeyBundles()
        )

        // Fail the first request; the reglock is invalid.
        let failResponse = TSRequestOWSURLSessionMock.Response(
            urlSuffix: expectedRecoveryPwRequest.url!.absoluteString,
            statusCode: RegistrationServiceResponses.AccountCreationResponseCodes.reglockFailed.rawValue,
            bodyJson: EncodableRegistrationLockFailureResponse(
                timeRemainingMs: 10,
                svr2AuthCredential: Stubs.svr2AuthCredential
            )
        )
        mockURLSession.addResponse(failResponse, atTime: firstRegistrationTime + 1, on: scheduler)

        // Once the request fails, we should try again with the reglock
        // token, this time.
        mockURLSession.addResponse(failResponse, atTime: secondRegistrationTime + 1, on: scheduler)

        // Once the second request fails, it should try an start a session.
        scheduler.run(atTime: sessionStartTime - 1) {
            // We'll ask for a push challenge, though we don't need to resolve it in this test.
            self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
                return Guarantee<String>.pending().0
            }

            // Resolve with a session.
            self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: false)),
                atTime: sessionStartTime + 1
            )
        }

        // Then when it gets back the session, it should immediately ask for
        // a verification code to be sent.
        scheduler.run(atTime: sendVerificationCodeTime - 1) {
            // Resolve with an updated session.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: true)),
                atTime: sendVerificationCodeTime + 1
            )
        }

        #expect(svr.hasMasterKey)
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == sendVerificationCodeTime + 1)

        // Now we should expect to be at verification code entry since we already set the phone number.
        // No exit allowed since we've already started trying to create the account.
        #expect(nextStep.value == .verificationCodeEntry(
            self.stubs.verificationCodeEntryState(mode: mode, exitConfigOverride: .noExitAllowed)
        ))
        // We want to have wiped our master key; we failed reglock, which means the key itself is
        // wrong.
        #expect(svr.hasMasterKey.negated)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testRegRecoveryPwPath_retryNetworkError(testCase: TestCase) throws {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode
        var actualSteps = [TestStep]()

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        // Set a PIN on disk.
        ows2FAManagerMock.pinCodeMock = { Stubs.pinCode }

        let (initialMasterKey, finalMasterKey) = buildKeyDataMocks(testCase)
        svr.hasMasterKey = true

        // Run the scheduler for a bit; we don't care about timing these bits.
        scheduler.start()

        // NOTE: We expect to skip opening path steps because
        // if we have a SVR master key locally, this _must_ be
        // a previously registered device, and we can skip intros.

        // We haven't set a phone number so it should ask for that.
        #expect(coordinator.nextStep().value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode)))

        // Give it a phone number, which should show the PIN entry step.
        var nextStep = coordinator.submitE164(Stubs.e164)
        // Now it should ask for the PIN to confirm the user knows it.
        #expect(nextStep.value == .pinEntry(Stubs.pinEntryStateForRegRecoveryPath(mode: mode)))

        // Now we want to control timing so we can verify things happened in the right order.
        scheduler.stop()
        scheduler.adjustTime(to: 0)

        // Give it the pin code, which should make it try and register.
        nextStep = coordinator.submitPINCode(Stubs.pinCode)

        // Before registering at t=0, it should ask for push tokens to give the registration.
        // When it retries at t=3, it will ask again.
        pushRegistrationManagerMock.requestPushTokenMock = {
            switch self.scheduler.currentTime {
            case 0:
                actualSteps.append(.requestPushToken)
                return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 1)
            case 3:
                actualSteps.append(.requestPushToken)
                return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 4)
            default:
                Issue.record("Got unexpected push tokens request")
                return .value(.timeout)
            }
        }
        // Every time we register we also ask for prekeys.
        preKeyManagerMock.createPreKeysMock = {
            switch self.scheduler.currentTime {
            case 1, 4:
                actualSteps.append(.createPreKeys)
                return .value(Stubs.prekeyBundles())
            default:
                Issue.record("Got unexpected push tokens request")
                return .init(error: PreKeyError())
            }
        }
        // And we finalize them after.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            switch self.scheduler.currentTime {
            case 3:
                actualSteps.append(.finalizePreKeys)
                #expect(didSucceed.negated)
                return .value(())
            case 5:
                actualSteps.append(.finalizePreKeys)
                #expect(didSucceed)
                return .value(())
            default:
                Issue.record("Got unexpected push tokens request")
                return .init(error: PreKeyError())
            }
        }

        let expectedRecoveryPwRequest = RegistrationRequestFactory.createAccountRequest(
            verificationMethod: .recoveryPassword(initialMasterKey.regRecoveryPw),
            e164: Stubs.e164,
            authPassword: "", // Doesn't matter for request generation.
            accountAttributes: Stubs.accountAttributes(initialMasterKey),
            skipDeviceTransfer: true,
            apnRegistrationId: Stubs.apnsRegistrationId,
            prekeyBundles: Stubs.prekeyBundles()
        )

        // Fail the request at t=3 with a network error.
        let failResponse = TSRequestOWSURLSessionMock.Response.networkError(
            matcher: { _ in
                actualSteps.append(.failedRequest)
                return true
            },
            url: expectedRecoveryPwRequest.url!
        )
        mockURLSession.addResponse(failResponse, atTime: 3, on: scheduler)

        let identityResponse = Stubs.accountIdentityResponse()
        var authPassword: String!

        // Once the first request fails, at t=3, it should retry.
        scheduler.run(atTime: 2) {
            // Resolve with success at t=5
            let expectedRequest = RegistrationRequestFactory.createAccountRequest(
                verificationMethod: .recoveryPassword(initialMasterKey.regRecoveryPw),
                e164: Stubs.e164,
                authPassword: "", // Doesn't matter for request generation.
                accountAttributes: Stubs.accountAttributes(initialMasterKey),
                skipDeviceTransfer: true,
                apnRegistrationId: Stubs.apnsRegistrationId,
                prekeyBundles: Stubs.prekeyBundles()
            )

            self.mockURLSession.addResponse(
                TSRequestOWSURLSessionMock.Response(
                    matcher: { request in
                        if request.url == expectedRequest.url {
                            actualSteps.append(.createAccount)
                            // The password is generated internally by RegistrationCoordinator.
                            // Extract it so we can check that the same password sent to the server
                            // to register is used later for other requests.
                            authPassword = request.authPassword
                            return true
                        }
                        return false
                    },
                    statusCode: 200,
                    bodyData: try! JSONEncoder().encode(identityResponse)
                ),
                atTime: 5,
                on: self.scheduler
            )
        }

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: identityResponse.aci,
                pni: identityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // When registered at t=5, it should try and sync pre-keys. Succeed at t=6.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            actualSteps.append(.rotateOneTimePreKeys)
            #expect(self.scheduler.currentTime == 5)
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return self.scheduler.promise(resolvingWith: (), atTime: 6)
        }

        // We haven't done a SVR backup; that should happen at t=6. Succeed at t=7.
        svr.backupMasterKeyMock = { pin, masterKey, authMethod in
            actualSteps.append(.backupMasterKey)
            #expect(pin == Stubs.pinCode)
            #expect(masterKey.rawData == finalMasterKey.rawData)
            // We don't have a SVR auth credential, it should use chat server creds.
            #expect(authMethod == .chatServerAuth(expectedAuthedAccount()))
            self.svr.hasMasterKey = true
            return self.scheduler.promise(resolvingWith: masterKey, atTime: 8)
        }

        // Once we back up to svr at t=7, we should restore from storage service.
        // Succeed at t=8.
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            actualSteps.append(.restoreStorageService)
            #expect(auth.authedAccount == expectedAuthedAccount())

            if self.scheduler.currentTime == 6 {
                switch masterKeySource {
                case .explicit(let explicitMasterKey):
                    #expect(initialMasterKey.rawData == explicitMasterKey.rawData)
                default:
                    Issue.record("Unexpected master key used in storage service operation.")
                }
                return self.scheduler.promise(resolvingWith: (), atTime: 7)
            } else if self.scheduler.currentTime == 8 {
                switch masterKeySource {
                case .explicit(let explicitMasterKey):
                    #expect(finalMasterKey.rawData == explicitMasterKey.rawData)
                default:
                    Issue.record("Unexpected master key used in storage service operation.")
                }
                return self.scheduler.promise(resolvingWith: (), atTime: 9)
            } else {
                Issue.record("Method called at unexpected time")
                // Not the correct time, but moves things forward
                return self.scheduler.promise(resolvingWith: (), atTime: 9)
            }
        }

        // Once we restore from storage service at t=8, we should attempt to
        // reclaim our username. Succeed at t=9.
        let mockUsernameLink: Usernames.UsernameLink = .mocked
        localUsernameManagerMock.startingUsernameState = .available(username: "boba.42", usernameLink: mockUsernameLink)
        usernameApiClientMock.confirmReservedUsernameMock = { _, _, chatServiceAuth in
            actualSteps.append(.confirmReservedUsername)
            #expect(chatServiceAuth == .explicit(
                aci: identityResponse.aci,
                deviceId: .primary,
                password: authPassword
            ))
            return self.scheduler.promise(
                resolvingWith: .success(usernameLinkHandle: mockUsernameLink.handle),
                atTime: 10
            )
        }

        // Once we do the storage service restore at t=9,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(finalMasterKey),
            auth: .implicit() // // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            TSRequestOWSURLSessionMock.Response(
                matcher: { request in
                    if request.url == expectedAttributesRequest.url {
                        actualSteps.append(.updateAccountAttribute)
                        return true
                    }
                    return false
                },
                statusCode: 200,
                bodyData: nil
            ),
            atTime: 11,
            on: scheduler
        )

        scheduler.runUntilIdle()

        var expectedSteps: [TestStep] = [
            .requestPushToken,
            .createPreKeys,
            .failedRequest,
            .finalizePreKeys,
            .requestPushToken,
            .createPreKeys,
            .createAccount,
            .finalizePreKeys,
            .rotateOneTimePreKeys,
            // .restoreStorageService, // If going from MasterKey -> AEP
            .backupMasterKey,
            // .restoreStorageService,
            .confirmReservedUsername,
            .updateAccountAttribute
        ]

        if testCase.newKey == .accountEntropyPool && testCase.oldKey != .accountEntropyPool {
            expectedSteps.insert(.restoreStorageService, at: 9)
        } else {
            expectedSteps.insert(.restoreStorageService, at: 10)
        }

        #expect(actualSteps == expectedSteps)

        #expect(nextStep.value == .done)

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    // MARK: - SVR Auth Credential Path

    @MainActor
    @Test(arguments: Self.testCases())
    func testSVRAuthCredentialPath_happyPath(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Run the scheduler for a bit; we don't care about timing these bits.
        scheduler.start()

        // Don't care about timing, just start it.
        setupDefaultAccountAttributes()

        // Set profile info so we skip those steps.
        self.setAllProfileInfo()

        var actualSteps = [String]()

        // Put some auth credentials in storage.
        let svr2CredentialCandidates: [SVR2AuthCredential] = [
            Stubs.svr2AuthCredential,
            SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "aaaa", password: "abc")),
            SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "zzzz", password: "xyz")),
            SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "0000", password: "123"))
        ]
        svrAuthCredentialStore.svr2Dict = Dictionary(grouping: svr2CredentialCandidates, by: \.credential.username).mapValues { $0.first! }

        // Get past the opening.
        goThroughOpeningHappyPath(
            coordinator: coordinator,
            mode: mode,
            expectedNextStep: .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode))
        )

        // Give it a phone number, which should cause it to check the auth credentials.
        // Match the main auth credential.
        let expectedSVR2CheckRequest = RegistrationRequestFactory.svr2AuthCredentialCheckRequest(
            e164: Stubs.e164,
            credentials: svr2CredentialCandidates
        )
        mockURLSession.addResponse(TSRequestOWSURLSessionMock.Response(
            urlSuffix: expectedSVR2CheckRequest.url!.absoluteString,
            statusCode: 200,
            bodyJson: RegistrationServiceResponses.SVR2AuthCheckResponse(matches: [
                "\(Stubs.svr2AuthCredential.credential.username):\(Stubs.svr2AuthCredential.credential.password)": .match,
                "aaaa:abc": .notMatch,
                "zzzz:xyz": .invalid,
                "0000:123": .unknown
            ])
        ))

        let nextStep = coordinator.submitE164(Stubs.e164).value

        // At this point, we should be asking for PIN entry so we can use the credential
        // to recover the SVR master key.
        #expect(nextStep == .pinEntry(Stubs.pinEntryStateForSVRAuthCredentialPath(mode: mode)))
        // We should have wiped the invalid and unknown credentials.
        let remainingCredentials = svrAuthCredentialStore.svr2Dict
        #expect(remainingCredentials[Stubs.svr2AuthCredential.credential.username] != nil)
        #expect(remainingCredentials["aaaa"] != nil)
        #expect(remainingCredentials["zzzz"] == nil)
        #expect(remainingCredentials["0000"] == nil)
        // SVR should be untouched.
        #expect(svrAuthCredentialStore.svr2Dict[Stubs.svr2AuthCredential.credential.username] != nil)

        scheduler.stop()
        scheduler.adjustTime(to: 0)

        let (initialMasterKey, finalMasterKey) = buildKeyDataMocks(testCase)

        // Enter the PIN, which should try and recover from SVR.
        // Once we do that, it should follow the Reg Recovery Password Path.
        let nextStepPromise = coordinator.submitPINCode(Stubs.pinCode)

        // At t=1, resolve the key restoration from SVR and have it start returning the key.
        svr.restoreKeysMock = { pin, authMethod in
            actualSteps.append("restoreKeys")
            #expect(self.scheduler.currentTime == 0)
            #expect(pin == Stubs.pinCode)
            #expect(authMethod == .svrAuth(Stubs.svr2AuthCredential, backup: nil))
            self.svr.hasMasterKey = true
            return self.scheduler.guarantee(resolvingWith: .success(initialMasterKey), atTime: 1)
        }

        // Before registering at t=1, it should ask for push tokens to give the registration.
        pushRegistrationManagerMock.requestPushTokenMock = {
            actualSteps.append("requestPushToken")
            #expect(self.scheduler.currentTime == 1)
            return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 2)
        }
        // Every time we register we also ask for prekeys.
        preKeyManagerMock.createPreKeysMock = {
            actualSteps.append("createPreKeys")
            switch self.scheduler.currentTime {
            case 2:
                return .value(Stubs.prekeyBundles())
            default:
                Issue.record("Got unexpected push tokens request")
                return .init(error: PreKeyError())
            }
        }
        // And we finalize them after.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            actualSteps.append("finalizePreKeys")
            switch self.scheduler.currentTime {
            case 3:
                #expect(didSucceed)
                return .value(())
            default:
                Issue.record("Got unexpected push tokens request")
                return .init(error: PreKeyError())
            }
        }

        // Now still at t=2 it should make a reg recovery pw request, resolve it at t=3.
        let accountIdentityResponse = Stubs.accountIdentityResponse()
        var authPassword: String!
        let expectedRegRecoveryPwRequest = RegistrationRequestFactory.createAccountRequest(
            verificationMethod: .recoveryPassword(initialMasterKey.regRecoveryPw),
            e164: Stubs.e164,
            authPassword: "", // Doesn't matter for request generation.
            accountAttributes: Stubs.accountAttributes(initialMasterKey),
            skipDeviceTransfer: true,
            apnRegistrationId: Stubs.apnsRegistrationId,
            prekeyBundles: Stubs.prekeyBundles()
        )
        self.mockURLSession.addResponse(
            TSRequestOWSURLSessionMock.Response(
                matcher: { request in
                    actualSteps.append("createAccount")
                    #expect(self.scheduler.currentTime == 2)
                    authPassword = request.authPassword
                    return request.url == expectedRegRecoveryPwRequest.url
                },
                statusCode: 200,
                bodyJson: accountIdentityResponse
            ),
            atTime: 3,
            on: self.scheduler
        )

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: accountIdentityResponse.aci,
                pni: accountIdentityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // When registered at t=3, it should try and create pre-keys.
        // Resolve at t=4.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            actualSteps.append("rotateOneTimePreKeys")
            #expect(self.scheduler.currentTime == 3)
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return self.scheduler.promise(resolvingWith: (), atTime: 4)
        }

        // At t=4 once we create pre-keys, we should back up to svr.
        svr.backupMasterKeyMock = { pin, masterKey, authMethod in
            actualSteps.append("backupMasterKey")
            let expectedTime = switch testCase.newKey {
            case .accountEntropyPool: 5
            default: 4
            }
            #expect(self.scheduler.currentTime == expectedTime)
            #expect(pin == Stubs.pinCode)
            #expect(masterKey.rawData == finalMasterKey.rawData)
            #expect(authMethod == .svrAuth(
                Stubs.svr2AuthCredential,
                backup: .chatServerAuth(expectedAuthedAccount())
            ))
            return self.scheduler.promise(resolvingWith: masterKey, atTime: 6)
        }

        // At t=5 once we back up to svr, we should restore from storage service.
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            #expect(auth.authedAccount == expectedAuthedAccount())
            actualSteps.append("restoreStorageService")
            if self.scheduler.currentTime == 4 {
                switch masterKeySource {
                case .explicit(let explicitMasterKey):
                    #expect(initialMasterKey.rawData == explicitMasterKey.rawData)
                default:
                    Issue.record("Unexpected master key used in storage service operation.")
                }
                return self.scheduler.promise(resolvingWith: (), atTime: 5)
            } else if self.scheduler.currentTime == 6 {
                switch masterKeySource {
                case .explicit(let explicitMasterKey):
                    #expect(finalMasterKey.rawData == explicitMasterKey.rawData)
                default:
                    Issue.record("Unexpected master key used in storage service operation.")
                }
                return self.scheduler.promise(resolvingWith: (), atTime: 7)
            } else {
                Issue.record("Method called at unexpected time")
                // Not the correct time, but moves things forward
                return self.scheduler.promise(resolvingWith: (), atTime: 7)
            }
        }

        storageServiceManagerMock.rotateManifestMock = { _, _ in
            actualSteps.append("rotateManifest")
            return .value(())
        }

        // Once we restore from storage service at t=6, we should attempt to
        // reclaim our username. Succeed at t=7.
        let mockUsernameLink: Usernames.UsernameLink = .mocked
        localUsernameManagerMock.startingUsernameState = .available(username: "boba.42", usernameLink: mockUsernameLink)
        usernameApiClientMock.confirmReservedUsernameMock = { _, _, chatServiceAuth in
            actualSteps.append("confirmReservedUsername")
            #expect(chatServiceAuth == .explicit(
                aci: accountIdentityResponse.aci,
                deviceId: .primary,
                password: authPassword
            ))
            return self.scheduler.promise(
                resolvingWith: .success(usernameLinkHandle: mockUsernameLink.handle),
                atTime: 8
            )
        }

        // And at t=7 once we do the storage service restore,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(finalMasterKey),
            auth: .implicit() // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            matcher: { request in
                actualSteps.append("updateAccountAttributes")
                return request.url == expectedAttributesRequest.url
            },
            statusCode: 200
        )

        for i in 0...6 {
            scheduler.run(atTime: i) {
                #expect(nextStepPromise.value == nil)
            }
        }

        scheduler.runUntilIdle()

        var expectedSteps = [
            "restoreKeys",
            "requestPushToken",
            "createPreKeys",
            "createAccount",
            "finalizePreKeys",
            "rotateOneTimePreKeys",
//            "restoreStorageService",
            "backupMasterKey",
//            "restoreStorageService",
            "confirmReservedUsername",
            "rotateManifest",
            "updateAccountAttributes"
        ]

        if testCase.newKey == .accountEntropyPool {
            expectedSteps.insert("restoreStorageService", at: 6)
        } else {
            expectedSteps.insert("restoreStorageService", at: 7)
        }

        #expect(actualSteps == expectedSteps)

        #expect(nextStepPromise.value == .done)

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSVRAuthCredentialPath_noMatchingCredentials(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Don't care about timing, just start it.
        scheduler.start()

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        // Put some auth credentials in storage.
        let credentialCandidates: [SVR2AuthCredential] = [
            Stubs.svr2AuthCredential,
            SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "aaaa", password: "abc")),
            SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "zzzz", password: "xyz")),
            SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "0000", password: "123"))
        ]
        svrAuthCredentialStore.svr2Dict = Dictionary(grouping: credentialCandidates, by: \.credential.username).mapValues { $0.first! }

        // Get past the opening.
        goThroughOpeningHappyPath(
            coordinator: coordinator,
            mode: mode,
            expectedNextStep: .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode))
        )

        scheduler.stop()
        scheduler.adjustTime(to: 0)

        // Give it a phone number, which should cause it to check the auth credentials.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // Don't give back any matches at t=2, which means we will want to create a session as a fallback.
        let expectedSVRCheckRequest = RegistrationRequestFactory.svr2AuthCredentialCheckRequest(
            e164: Stubs.e164,
            credentials: credentialCandidates
        )
        mockURLSession.addResponse(
            TSRequestOWSURLSessionMock.Response(
                urlSuffix: expectedSVRCheckRequest.url!.absoluteString,
                statusCode: 200,
                bodyJson: RegistrationServiceResponses.SVR2AuthCheckResponse(matches: [
                    "\(Stubs.svr2AuthCredential.credential.username):\(Stubs.svr2AuthCredential.credential.password)": .notMatch,
                    "aaaa:abc": .notMatch,
                    "zzzz:xyz": .invalid,
                    "0000:123": .unknown
                ])
            ),
            atTime: 2,
            on: scheduler
        )

        // Once the first request fails, at t=2, it should try an start a session.
        scheduler.run(atTime: 1) {
            // We'll ask for a push challenge, though we don't need to resolve it in this test.
            self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
                return Guarantee<String>.pending().0
            }

            // Resolve with a session at time 3.
            self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: false)),
                atTime: 3
            )
        }

        // Then when it gets back the session at t=3, it should immediately ask for
        // a verification code to be sent.
        scheduler.run(atTime: 3) {
            // Resolve with an updated session at time 4.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: true)),
                atTime: 4
            )
        }

        pushRegistrationManagerMock.requestPushTokenMock = { .value(.success(Stubs.apnsRegistrationId))}

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 4)

        // Now we should expect to be at verification code entry since we already set the phone number.
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))

        // We should have wipted the invalid and unknown credentials.
        let remainingCredentials = svrAuthCredentialStore.svr2Dict
        #expect(remainingCredentials[Stubs.svr2AuthCredential.credential.username] != nil)
        #expect(remainingCredentials["aaaa"] != nil)
        #expect(remainingCredentials["zzzz"] == nil)
        #expect(remainingCredentials["0000"] == nil)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSVRAuthCredentialPath_noMatchingCredentialsThenChangeNumber(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        // Don't care about timing, just start it.
        scheduler.start()

        // Set profile info so we skip those steps.
        setupDefaultAccountAttributes()

        // Put some auth credentials in storage.
        let credentialCandidates: [SVR2AuthCredential] = [
            Stubs.svr2AuthCredential
        ]
        svrAuthCredentialStore.svr2Dict = Dictionary(grouping: credentialCandidates, by: \.credential.username).mapValues { $0.first! }

        // Get past the opening.
        goThroughOpeningHappyPath(
            coordinator: coordinator,
            mode: mode,
            expectedNextStep: .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode))
        )

        scheduler.stop()
        scheduler.adjustTime(to: 0)

        let originalE164 = E164("+17875550100")!
        let changedE164 = E164("+17875550101")!

        // Give it a phone number, which should cause it to check the auth credentials.
        var nextStep = coordinator.submitE164(originalE164)

        // Don't give back any matches at t=2, which means we will want to create a session as a fallback.
        var expectedSVRCheckRequest = RegistrationRequestFactory.svr2AuthCredentialCheckRequest(
            e164: originalE164,
            credentials: credentialCandidates
        )
        mockURLSession.addResponse(
            TSRequestOWSURLSessionMock.Response(
                urlSuffix: expectedSVRCheckRequest.url!.absoluteString,
                statusCode: 200,
                bodyJson: RegistrationServiceResponses.SVR2AuthCheckResponse(matches: [
                    "\(Stubs.svr2AuthCredential.credential.username):\(Stubs.svr2AuthCredential.credential.password)": .notMatch
                ])
            ),
            atTime: 2,
            on: scheduler
        )

        // Once the first request fails, at t=2, it should try an start a session.
        scheduler.run(atTime: 1) {
            // We'll ask for a push challenge, though we don't need to resolve it in this test.
            self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
                return Guarantee<String>.pending().0
            }

            // Resolve with a session at time 3.
            self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(e164: originalE164, hasSentVerificationCode: false)),
                atTime: 3
            )
        }

        // Then when it gets back the session at t=3, it should immediately ask for
        // a verification code to be sent.
        scheduler.run(atTime: 3) {
            // Resolve with an updated session at time 4.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(self.stubs.session(hasSentVerificationCode: true)),
                atTime: 4
            )
        }

        pushRegistrationManagerMock.requestPushTokenMock = { .value(.success(Stubs.apnsRegistrationId))}

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 4)

        // Now we should expect to be at verification code entry since we already set the phone number.
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))

        // We should have wiped the invalid and unknown credentials.
        let remainingCredentials = svrAuthCredentialStore.svr2Dict
        #expect(remainingCredentials[Stubs.svr2AuthCredential.credential.username] != nil)

        // Now change the phone number; this should take us back to phone number entry.
        nextStep = coordinator.requestChangeE164()
        scheduler.runUntilIdle()
        #expect(nextStep.value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode)))

        // Give it a phone number, which should cause it to check the auth credentials again.
        nextStep = coordinator.submitE164(changedE164)

        // Give a match at t=5, so it registers via SVR auth credential.
        expectedSVRCheckRequest = RegistrationRequestFactory.svr2AuthCredentialCheckRequest(
            e164: changedE164,
            credentials: credentialCandidates
        )
        mockURLSession.addResponse(
            TSRequestOWSURLSessionMock.Response(
                urlSuffix: expectedSVRCheckRequest.url!.absoluteString,
                statusCode: 200,
                bodyJson: RegistrationServiceResponses.SVR2AuthCheckResponse(matches: [
                    "\(Stubs.svr2AuthCredential.credential.username):\(Stubs.svr2AuthCredential.credential.password)": .match
                ])
            ),
            atTime: 5,
            on: scheduler
        )

        // Now it should ask for PIN entry; we are on the SVR auth credential path.
        scheduler.runUntilIdle()
        #expect(nextStep.value == .pinEntry(Stubs.pinEntryStateForSVRAuthCredentialPath(mode: mode)))
    }

    // MARK: - Session Path

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_happyPath(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        let accountEntropyPool = AccountEntropyPool()
        let newMasterKey = accountEntropyPool.getMasterKey()
        if testCase.newKey == .accountEntropyPool {
            missingKeyGenerator.accountEntropyPool = { accountEntropyPool }
        } else {
            missingKeyGenerator.masterKey = { newMasterKey }
        }
        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        scheduler.tick()

        var nextStep: Guarantee<RegistrationStep>!

        // Submit a code at t=5.
        scheduler.run(atTime: 5) {
            nextStep = coordinator.submitVerificationCode(Stubs.pinCode)
        }

        // At t=7, give back a verified session.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: true
            )),
            atTime: 7
        )

        let accountIdentityResponse = Stubs.accountIdentityResponse()
        var authPassword: String!

        // That means at t=7 it should try and register with the verified
        // session; be ready for that starting at t=6 (but not before).

        // Before registering at t=7, it should ask for push tokens to give the registration.
        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 7)
            return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 8)
        }

        // It should also fetch the prekeys for account creation
        preKeyManagerMock.createPreKeysMock = {
            #expect(self.scheduler.currentTime == 8)
            return self.scheduler.promise(resolvingWith: Stubs.prekeyBundles(), atTime: 9)
        }

        scheduler.run(atTime: 8) {
            let expectedRequest = RegistrationRequestFactory.createAccountRequest(
                verificationMethod: .sessionId(Stubs.sessionId),
                e164: Stubs.e164,
                authPassword: "", // Doesn't matter for request generation.
                accountAttributes: Stubs.accountAttributes(newMasterKey),
                skipDeviceTransfer: true,
                apnRegistrationId: Stubs.apnsRegistrationId,
                prekeyBundles: Stubs.prekeyBundles()
            )
            // Resolve it at t=10
            self.mockURLSession.addResponse(
                TSRequestOWSURLSessionMock.Response(
                    matcher: { request in
                        authPassword = request.authPassword
                        return request.url == expectedRequest.url
                    },
                    statusCode: 200,
                    bodyJson: accountIdentityResponse
                ),
                atTime: 10,
                on: self.scheduler
            )
        }

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: accountIdentityResponse.aci,
                pni: accountIdentityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // Once we are registered at t=10, we should finalize prekeys.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            #expect(self.scheduler.currentTime == 10)
            #expect(didSucceed)
            return self.scheduler.promise(resolvingWith: (), atTime: 11)
        }

        // Then we should try and create one time pre-keys
        // with the credentials we got in the identity response.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            #expect(self.scheduler.currentTime == 11)
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return self.scheduler.promise(resolvingWith: (), atTime: 12)
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 12)

        // Now we should ask to create a PIN.
        // No exit allowed since we've already started trying to create the account.
        #expect(nextStep.value == .pinEntry(
            Stubs.pinEntryStateForPostRegCreate(mode: mode, exitConfigOverride: .noExitAllowed)
        ))

        // Confirm the pin first.
        nextStep = coordinator.setPINCodeForConfirmation(.stub())
        scheduler.runUntilIdle()
        // No exit allowed since we've already started trying to create the account.
        #expect(nextStep.value == .pinEntry(
            Stubs.pinEntryStateForPostRegConfirm(mode: mode, exitConfigOverride: .noExitAllowed)
        ))

        scheduler.adjustTime(to: 0)

        // When we submit the pin, it should backup with SVR.
        nextStep = coordinator.submitPINCode(Stubs.pinCode)

        // Finish the validation at t=1.
        svr.backupMasterKeyMock = { pin, masterKey, authMethod in
            #expect(self.scheduler.currentTime == 0)
            #expect(pin == Stubs.pinCode)
            #expect(masterKey.rawData == newMasterKey.rawData)
            #expect(authMethod == .chatServerAuth(expectedAuthedAccount()))
            return self.scheduler.promise(resolvingWith: masterKey, atTime: 1)
        }

        // At t=1 once we sync push tokens, we should restore from storage service.
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            #expect(self.scheduler.currentTime == 1)
            #expect(auth.authedAccount == expectedAuthedAccount())
            switch masterKeySource {
            case .explicit(let explicitMasterKey):
                #expect(newMasterKey.rawData == explicitMasterKey.rawData)
            default:
                Issue.record("Unexpected master key used in storage service operation.")
            }
            return self.scheduler.promise(resolvingWith: (), atTime: 2)
        }

        // Once we restore from storage service, we should attempt to reclaim
        // our username. For this test, let's fail at t=3. This should have
        // no different impact on the rest of registration.
        let mockUsernameLink: Usernames.UsernameLink = .mocked
        localUsernameManagerMock.startingUsernameState = .available(username: "boba.42", usernameLink: mockUsernameLink)
        usernameApiClientMock.confirmReservedUsernameMock = { _, _, chatServiceAuth in
            #expect(self.scheduler.currentTime == 2)
            #expect(chatServiceAuth == .explicit(
                aci: accountIdentityResponse.aci,
                deviceId: .primary,
                password: authPassword
            ))
            return self.scheduler.promise(
                rejectedWith: OWSGenericError("Something went wrong :("),
                atTime: 3
            )
        }

        // And at t=3 once we do the storage service restore,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(newMasterKey),
            auth: .implicit() // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            matcher: { request in
                #expect(self.scheduler.currentTime == 3)
                return request.url == expectedAttributesRequest.url
            },
            statusCode: 200
        )

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 3)

        #expect(nextStep.value == .done)

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_invalidE164(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        switch mode {
        case .registering, .changingNumber:
            break
        case .reRegistering:
            // no changing the number when reregistering
            return
        }

        setUpSessionPath(coordinator: coordinator, mode: mode)

        let badE164 = E164("+15555555555")!

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(badE164)

        // At t=2, reject for invalid argument (the e164).
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .invalidArgument,
            atTime: 2
        )

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)

        // It should put us on the phone number entry screen again
        // with an error.
        #expect(
            nextStep.value ==
                .phoneNumberEntry(
                    self.stubs.phoneNumberEntryState(
                        mode: mode,
                        previouslyEnteredE164: badE164,
                        withValidationErrorFor: .invalidArgument
                    )
                )
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_rateLimitSessionCreation(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        let retryTimeInterval: TimeInterval = 5

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, reject with a rate limit.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .retryAfter(retryTimeInterval),
            atTime: 2
        )

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)

        // It should put us on the phone number entry screen again
        // with an error.
        #expect(
            nextStep.value ==
                .phoneNumberEntry(
                    self.stubs.phoneNumberEntryState(
                        mode: mode,
                        previouslyEnteredE164: Stubs.e164,
                        withValidationErrorFor: .retryAfter(retryTimeInterval)
                    )
                )
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_cantSendFirstSMSCode(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session, but with SMS code rate limiting already.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 10,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // It should put us on the verification code entry screen with an error.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)
        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                    mode: mode,
                    nextSMS: 10,
                    nextVerificationAttempt: nil,
                    validationError: .smsResendTimeout
                ))
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_landline(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        var nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session that's ready to go.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: nil, /* initially calling unavailable */
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should try and send a code.
        // Be ready for that starting at t=1 (but not before).
        scheduler.run(atTime: 1) {
            // Resolve with a transport error at time 3,
            // and no next verification attempt on the session,
            // so it counts as transport failure with no code sent.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .transportError(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: nil,
                    nextCall: 0, /* now sms unavailable but calling is */
                    nextVerificationAttempt: nil,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 3
            )
        }

        // At t=3 we should get back the code entry step,
        // with a validation error for the sms transport.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 3)
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(
            mode: mode,
            nextSMS: nil,
            nextVerificationAttempt: nil,
            validationError: .failedInitialTransport(failedTransport: .sms)
        )))

        // If we resend via voice, that should put us in a happy path.
        // Resolve with a success at t=4.
        self.sessionManager.didRequestCode = false
        self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: 0,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 4
        )

        nextStep = coordinator.requestVoiceCode()

        // At t=4 we should get back the code entry step.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 4)
        #expect(sessionManager.didRequestCode)
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_landline_submitCodeWithNoneSentYet(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        var nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session that's ready to go.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should try and send a code.
        // Be ready for that starting at t=1 (but not before).
        scheduler.run(atTime: 1) {
            // Resolve with a transport error at time 3,
            // and no next verification attempt on the session,
            // so it counts as transport failure with no code sent.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .transportError(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: nil,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 3
            )
        }

        // At t=3 we should get back the code entry step,
        // with a validation error for the sms transport.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 3)
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(
            mode: mode,
            nextVerificationAttempt: nil,
            validationError: .failedInitialTransport(failedTransport: .sms)
        )))

        // If we try and submit a code, we should get an error sheet
        // because a code never got sent in the first place.
        // (If the server rejects the submission, which it obviously should).
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .disallowed(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 4
        )

        nextStep = coordinator.submitVerificationCode(Stubs.verificationCode)

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 4)

        // The server says no code is available to submit. We know
        // we never sent a code, so show a unique error for that
        // but keep the user on the code entry screen so they can
        // retry sending a code with a transport method of their choice.

        #expect(
            nextStep.value ==
                .showErrorSheet(.submittingVerificationCodeBeforeAnyCodeSent)
        )
        nextStep = coordinator.nextStep()
        scheduler.runUntilIdle()
        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                    mode: mode,
                    nextVerificationAttempt: nil,
                    validationError: .failedInitialTransport(failedTransport: .sms)
                ))
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_rateLimitFirstSMSCode(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // We'll ask for a push challenge, though we won't resolve it in this test.
        self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            return Guarantee<String>.pending().0
        }

        // At t=2, give back a session that's ready to go.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should try and send a code.
        // Be ready for that starting at t=1 (but not before).
        scheduler.run(atTime: 1) {
            // Reject with a timeout.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .retryAfterTimeout(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 10,
                    nextCall: 0,
                    nextVerificationAttempt: nil,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 3
            )
        }

        // It should put us on the phone number entry screen again
        // with an error.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 3)
        #expect(
            nextStep.value ==
                .phoneNumberEntry(
                    self.stubs.phoneNumberEntryState(
                        mode: mode,
                        previouslyEnteredE164: Stubs.e164,
                        withValidationErrorFor: .retryAfter(10)
                    )
                )
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_changeE164(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        let originalE164 = E164("+17875550100")!
        let changedE164 = E164("+17875550101")!

        // Give it a phone number, which should cause it to start a session.
        var nextStep = coordinator.submitE164(originalE164)

        // We'll ask for a push challenge, though we won't resolve it in this test.
        self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            return Guarantee<String>.pending().0
        }

        // At t=2, give back a session that's ready to go.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: originalE164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should try and send a code.
        // Be ready for that starting at t=1 (but not before).
        scheduler.run(atTime: 1) {
            // Give back a session with a sent code.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: originalE164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 3
            )
        }

        // We should be on the verification code entry screen.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 3)
        #expect(
            nextStep.value ==
                .verificationCodeEntry(
                    self.stubs.verificationCodeEntryState(mode: mode, e164: originalE164)
                )
        )

        // Ask to change the number; this should put us back on phone number entry.
        nextStep = coordinator.requestChangeE164()
        scheduler.runUntilIdle()
        #expect(
            nextStep.value ==
                .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode))
        )

        // Give it the new phone number, which should cause it to start a session.
        nextStep = coordinator.submitE164(changedE164)

        // We'll ask for a push challenge, though we won't resolve it in this test.
        self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            return Guarantee<String>.pending().0
        }

        // At t=5, give back a session that's ready to go.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: changedE164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 5
        )

        // Once we get that session at t=5, we should try and send a code.
        // Be ready for that starting at t=4 (but not before).
        scheduler.run(atTime: 4) {
            // Give back a session with a sent code.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: changedE164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 6
            )
        }

        // We should be on the verification code entry screen.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 6)
        #expect(
            nextStep.value ==
                .verificationCodeEntry(
                    self.stubs.verificationCodeEntryState(mode: mode, e164: changedE164)
                )
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_captchaChallenge(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        var nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session with a captcha challenge.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.captcha],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should get a captcha step back.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)
        #expect(nextStep.value == .captchaChallenge)

        scheduler.tick()

        // Submit a captcha challenge at t=4.
        scheduler.run(atTime: 4) {
            nextStep = coordinator.submitCaptcha(Stubs.captchaToken)
        }

        // At t=6, give back a session without the challenge.
        self.sessionManager.fulfillChallengeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 6
        )

        // That means at t=6 it should try and send a code;
        // be ready for that starting at t=5 (but not before).
        scheduler.run(atTime: 5) {
            // Resolve with a session at time 7.
            // The session has a sent code, but requires a challenge to send
            // a code again. That should be ignored until we ask to send another code.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: false,
                    requestedInformation: [.captcha],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 7
            )
        }

        // At t=7, we should get back the code entry step.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 7)
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))

        // Now try and resend a code, which should hit us with the captcha challenge immediately.
        scheduler.start()
        #expect(coordinator.requestSMSCode().value == .captchaChallenge)
        scheduler.stop()

        // Submit a captcha challenge at t=8.
        scheduler.run(atTime: 8) {
            nextStep = coordinator.submitCaptcha(Stubs.captchaToken)
        }

        // At t=10, give back a session without the challenge.
        self.sessionManager.fulfillChallengeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: 0,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 10
        )

        // This means at t=10 when we fulfill the challenge, it should
        // immediately try and send the code that couldn't be sent before because
        // of the challenge.
        // Reply to this at t=12.
        self.stubs.date = date.addingTimeInterval(10)
        let secondCodeDate = date
        scheduler.run(atTime: 9) {
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: secondCodeDate,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 12
            )
        }

        // Ensure that at t=11, before we've gotten the request code response,
        // we don't have a result yet.
        scheduler.run(atTime: 11) {
            #expect(nextStep.value == nil)
        }

        // Once all is done, we should have a new code and be back on the code
        // entry screen.
        // TODO[Registration]: test that the "next SMS code" state is properly set
        // given the new sms code date above.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 12)
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_pushChallenge(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.success(Stubs.apnsRegistrationId))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // Prepare to provide the challenge token.
        let (challengeTokenPromise, challengeTokenFuture) = Guarantee<String>.pending()
        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            #expect(self.scheduler.currentTime == 2)
            return challengeTokenPromise
        }

        // At t=2, give back a session with a push challenge.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.pushChallenge],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // At t=3, give the push challenge token. Also prepare to handle its usage, and the
        // resulting request for another SMS code.
        scheduler.run(atTime: 3) {
            challengeTokenFuture.resolve("a pre-auth challenge token")

            self.sessionManager.fulfillChallengeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 4
            )

            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: false,
                    requestedInformation: [.pushChallenge],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 6
            )

            // We should still be waiting.
            #expect(nextStep.value == nil)
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 6)

        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode))
        )
        #expect(
            sessionManager.latestChallengeFulfillment ==
                .pushChallenge("a pre-auth challenge token")
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_pushChallengeTimeoutAfterResolutionThatTakesTooLong(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        let sessionStartsAt = 2

        setUpSessionPath(coordinator: coordinator, mode: mode)

        dateProvider = { self.date.addingTimeInterval(TimeInterval(self.scheduler.currentTime)) }

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.success(Stubs.apnsRegistrationId))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // Prepare to provide the challenge token.
        let (challengeTokenPromise, challengeTokenFuture) = Guarantee<String>.pending()
        var receivePreAuthChallengeTokenCount = 0
        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            switch receivePreAuthChallengeTokenCount {
            case 0, 1:
                #expect(self.scheduler.currentTime == sessionStartsAt)
            case 2:
                let minWaitTime = Int(RegistrationCoordinatorImpl.Constants.pushTokenMinWaitTime / self.scheduler.secondsPerTick)
                #expect(self.scheduler.currentTime == sessionStartsAt + minWaitTime)
            default:
                Issue.record("Calling preAuthChallengeToken too many times")
            }
            receivePreAuthChallengeTokenCount += 1
            return challengeTokenPromise
        }

        // At t=2, give back a session with a push challenge.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.pushChallenge],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: sessionStartsAt
        )

        // Take too long to resolve with the challenge token.
        let pushChallengeTimeout = Int(RegistrationCoordinatorImpl.Constants.pushTokenTimeout / scheduler.secondsPerTick)
        let receiveChallengeTokenTime = sessionStartsAt + pushChallengeTimeout + 1
        scheduler.run(atTime: receiveChallengeTokenTime) {
            challengeTokenFuture.resolve("challenge token that should be ignored")
        }

        scheduler.advance(to: sessionStartsAt + pushChallengeTimeout - 1)
        #expect(nextStep.value == nil)

        scheduler.tick()
        #expect(nextStep.value == .showErrorSheet(.sessionInvalidated))

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == receiveChallengeTokenTime)

        // One time to set up, one time for the min wait time, one time
        // for the full timeout.
        #expect(receivePreAuthChallengeTokenCount == 3)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_pushChallengeTimeoutAfterNoResolution(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        let pushChallengeMinTime = Int(RegistrationCoordinatorImpl.Constants.pushTokenMinWaitTime / scheduler.secondsPerTick)
        let pushChallengeTimeout = Int(RegistrationCoordinatorImpl.Constants.pushTokenTimeout / scheduler.secondsPerTick)

        let sessionStartsAt = 2
        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.success(Stubs.apnsRegistrationId))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // We'll never provide a challenge token and will just leave it around forever.
        let (challengeTokenPromise, _) = Guarantee<String>.pending()
        var receivePreAuthChallengeTokenCount = 0
        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            switch receivePreAuthChallengeTokenCount {
            case 0, 1:
                #expect(self.scheduler.currentTime == sessionStartsAt)
            case 2:
                #expect(self.scheduler.currentTime == sessionStartsAt + pushChallengeMinTime)
            default:
                Issue.record("Calling preAuthChallengeToken too many times")
            }
            receivePreAuthChallengeTokenCount += 1
            return challengeTokenPromise
        }

        // At t=2, give back a session with a push challenge.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.pushChallenge],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2 + pushChallengeMinTime + pushChallengeTimeout)
        #expect(nextStep.value == .showErrorSheet(.sessionInvalidated))

        // One time to set up, one time for the min wait time, one time
        // for the full timeout.
        #expect(receivePreAuthChallengeTokenCount == 3)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_pushChallengeWithoutPushNotificationsAvailable(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.pushUnsupported(description: ""))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // We'll ask for a push challenge, though we don't need to resolve it in this test.
        self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            #expect(self.scheduler.currentTime == 2)
            return Guarantee<String>.pending().0
        }

        // Require a push challenge, which we won't be able to answer.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.pushChallenge],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)
        #expect(
            nextStep.value ==
                .phoneNumberEntry(self.stubs.phoneNumberEntryState(
                    mode: mode,
                    previouslyEnteredE164: Stubs.e164
                ))
        )
        #expect(sessionManager.latestChallengeFulfillment == nil)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_preferPushChallengesIfWeCanAnswerThemImmediately(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.success(Stubs.apnsRegistrationId))
        }

        // Be ready to provide the push challenge token as soon as it's needed.
        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            #expect(self.scheduler.currentTime == 2)
            return .value("a pre-auth challenge token")
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session with multiple challenges.
        sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.captcha, .pushChallenge],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Be ready to handle push challenges as soon as we can.
        scheduler.run(atTime: 2) {
            self.sessionManager.fulfillChallengeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 4
            )
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 5
            )
        }

        // We should still be waiting at t=4.
        scheduler.run(atTime: 4) {
            #expect(nextStep.value == nil)
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 5)

        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode))
        )
        #expect(
            sessionManager.latestChallengeFulfillment ==
                .pushChallenge("a pre-auth challenge token")
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_prefersCaptchaChallengesIfWeCannotAnswerPushChallengeQuickly(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.success(Stubs.apnsRegistrationId))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // Prepare to provide the challenge token.
        let (challengeTokenPromise, challengeTokenFuture) = Guarantee<String>.pending()
        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            #expect(self.scheduler.currentTime == 2)
            return challengeTokenPromise
        }

        // At t=2, give back a session with multiple challenges.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.pushChallenge, .captcha],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Take too long to resolve with the challenge token.
        let pushChallengeTimeout = Int(RegistrationCoordinatorImpl.Constants.pushTokenTimeout / scheduler.secondsPerTick)
        let receiveChallengeTokenTime = pushChallengeTimeout + 1
        scheduler.run(atTime: receiveChallengeTokenTime - 1) {
            let date = self.stubs.date.addingTimeInterval(TimeInterval(receiveChallengeTokenTime))
            self.stubs.date = date
        }
        scheduler.run(atTime: receiveChallengeTokenTime) {
            challengeTokenFuture.resolve("challenge token that should be ignored")
        }

        // Once we get that session at t=2, we should wait a short time for the
        // push challenge token.
        let pushChallengeMinTime = Int(RegistrationCoordinatorImpl.Constants.pushTokenMinWaitTime / scheduler.secondsPerTick)

        // After that, we should get a captcha step back, because we haven't
        // yet received the push challenge token.
        scheduler.advance(to: 2 + pushChallengeMinTime)
        #expect(nextStep.value == .captchaChallenge)

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == receiveChallengeTokenTime)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_pushChallengeFastResolution(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.success(Stubs.apnsRegistrationId))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // Prepare to provide the challenge token.
        let pushChallengeMinTime = Int(RegistrationCoordinatorImpl.Constants.pushTokenMinWaitTime / scheduler.secondsPerTick)
        let receiveChallengeTokenTime = 2 + pushChallengeMinTime - 1

        let (challengeTokenPromise, challengeTokenFuture) = Guarantee<String>.pending()
        var receivePreAuthChallengeTokenCount = 0
        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
            switch receivePreAuthChallengeTokenCount {
            case 0, 1:
                #expect(self.scheduler.currentTime == 2)
            default:
                Issue.record("Calling preAuthChallengeToken too many times")
            }
            receivePreAuthChallengeTokenCount += 1
            return challengeTokenPromise
        }

        // At t=2, give back a session with multiple challenges.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.pushChallenge, .captcha],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Don't resolve the captcha token immediately, but quickly enough.
        scheduler.run(atTime: receiveChallengeTokenTime - 1) {
            let date = self.stubs.date.addingTimeInterval(TimeInterval(pushChallengeMinTime - 1))
            self.stubs.date = date
        }
        scheduler.run(atTime: receiveChallengeTokenTime) {
            // Also prep for the token's submission.
            self.sessionManager.fulfillChallengeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.stubs.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: receiveChallengeTokenTime + 1
            )

            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.stubs.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: false,
                    requestedInformation: [.pushChallenge],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: receiveChallengeTokenTime + 2
            )

            challengeTokenFuture.resolve("challenge token")
        }

        // Once we get that session, we should wait a short time for the
        // push challenge token and fulfill it.
        scheduler.advance(to: receiveChallengeTokenTime + 2)
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == receiveChallengeTokenTime + 2)

        #expect(receivePreAuthChallengeTokenCount == 2)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_ignoresPushChallengesIfWeCannotEverAnswerThem(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 0)
            return .value(.pushUnsupported(description: ""))
        }

        // Give it a phone number, which should cause it to start a session.
        let nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session with multiple challenges.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.captcha, .pushChallenge],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)
        #expect(nextStep.value == .captchaChallenge)
        #expect(sessionManager.latestChallengeFulfillment == nil)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_unknownChallenge(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        var nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session with a captcha challenge and an unknown challenge.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [.captcha],
                hasUnknownChallengeRequiringAppUpdate: true,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should get a captcha step back.
        // We have an unknown challenge, but we should do known challenges first!
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)
        #expect(nextStep.value == .captchaChallenge)

        scheduler.tick()

        // Submit a captcha challenge at t=4.
        scheduler.run(atTime: 4) {
            nextStep = coordinator.submitCaptcha(Stubs.captchaToken)
        }

        // At t=6, give back a session without the captcha but still with the
        // unknown challenge
        self.sessionManager.fulfillChallengeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: false,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: true,
                verified: false
            )),
            atTime: 6
        )

        // This means at t=6 we should get the app update banner.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 6)
        #expect(nextStep.value == .appUpdateBanner)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_wrongVerificationCode(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        // Now try and send the wrong code.
        let badCode = "garbage"

        // At t=1, give back a rejected argument response, its the wrong code.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .rejectedArgument(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: 0,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 1
        )

        let nextStep = coordinator.submitVerificationCode(badCode)

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 1)
        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                    mode: mode,
                    validationError: .invalidVerificationCode(invalidCode: badCode)
                ))
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_verificationCodeTimeouts(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        // At t=1, give back a retry response.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .retryAfterTimeout(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: 10,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 1
        )

        var nextStep = coordinator.submitVerificationCode(Stubs.verificationCode)

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 1)
        #expect(
            nextStep.value ==
            .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                mode: mode,
                nextVerificationAttempt: 10,
                validationError: .submitCodeTimeout
            ))
        )

        // Resend an sms code, time that out too at t=2.
        self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
            resolvingWith: .retryAfterTimeout(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 7,
                nextCall: 0,
                nextVerificationAttempt: 9,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        nextStep = coordinator.requestSMSCode()

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 2)
        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                    mode: mode,
                    nextSMS: 7,
                    nextVerificationAttempt: 9,
                    validationError: .smsResendTimeout
                ))
        )

        // Resend an voice code, time that out too at t=4.
        // Make the timeout SO short that it retries at t=4.
        self.sessionManager.didRequestCode = false
        self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
            resolvingWith: .retryAfterTimeout(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 6,
                nextCall: 0.1,
                nextVerificationAttempt: 8,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 4
        )

        // Be ready for the retry at t=4
        scheduler.run(atTime: 3) {
            // Ensure we called it the first time.
            #expect(self.sessionManager.didRequestCode)
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .retryAfterTimeout(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 5,
                    nextCall: 4,
                    nextVerificationAttempt: 8,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 5
            )
        }

        nextStep = coordinator.requestVoiceCode()

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 5)
        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                    mode: mode,
                    nextSMS: 5,
                    nextCall: 4,
                    nextVerificationAttempt: 8,
                    validationError: .voiceResendTimeout
                ))
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_disallowedVerificationCode(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        // At t=1, give back a disallowed response when submitting a code.
        // Make the session unverified. Together this will be interpreted
        // as meaning no code has been sent (via sms or voice) and one
        // must be requested.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .disallowed(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 1
        )

        var nextStep = coordinator.submitVerificationCode(Stubs.verificationCode)

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 1)

        // The server says no code is available to submit. But we think we tried
        // sending a code with local state. We want to be on the verification
        // code entry screen, with an error so the user retries sending a code.

        #expect(
            nextStep.value ==
                .showErrorSheet(.verificationCodeSubmissionUnavailable)
        )
        nextStep = coordinator.nextStep()
        scheduler.runUntilIdle()
        #expect(
            nextStep.value ==
                .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                    mode: mode,
                    nextVerificationAttempt: nil
                ))
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_timedOutVerificationCodeWithoutRetries(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        // At t=1, give back a retry response when submitting a code,
        // but with no ability to resubmit.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .retryAfterTimeout(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 1
        )

        var nextStep = coordinator.submitVerificationCode(Stubs.verificationCode)

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 1)
        #expect(
            nextStep.value ==
                .showErrorSheet(.verificationCodeSubmissionUnavailable)
        )
        nextStep = coordinator.nextStep()
        scheduler.runUntilIdle()
        #expect(
            nextStep.value ==
            .verificationCodeEntry(self.stubs.verificationCodeEntryState(
                mode: mode,
                nextVerificationAttempt: nil
            ))
        )
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_expiredSession(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        setUpSessionPath(coordinator: coordinator, mode: mode)

        // Give it a phone number, which should cause it to start a session.
        var nextStep = coordinator.submitE164(Stubs.e164)

        // At t=2, give back a session thats ready to go.
        self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )),
            atTime: 2
        )

        // Once we get that session at t=2, we should try and send a verification code.
        // Have that ready to go at t=1.
        scheduler.run(atTime: 1) {
            // We'll ask for a push challenge, though we won't resolve it.
            self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
                return Guarantee<String>.pending().0
            }

            // Resolve with a session at time 3.
            self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: 0,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 3
            )
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 3)

        // Now we should expect to be at verification code entry since we sent the code.
        #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))

        scheduler.tick()

        // Submit a code at t=5.
        scheduler.run(atTime: 5) {
            nextStep = coordinator.submitVerificationCode(Stubs.pinCode)
        }

        // At t=7, give back an expired session.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .invalidSession,
            atTime: 7
        )

        // That means at t=7 it should show an error, and then phone number entry.
        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 7)
        #expect(nextStep.value == .showErrorSheet(.sessionInvalidated))
        nextStep = coordinator.nextStep()
        scheduler.runUntilIdle()
        #expect(nextStep.value == .phoneNumberEntry(self.stubs.phoneNumberEntryState(
            mode: mode,
            previouslyEnteredE164: Stubs.e164
        )))
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_skipPINCode(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        let accountEntropyPool = AccountEntropyPool()
        let newMasterKey = accountEntropyPool.getMasterKey()
        if testCase.newKey == .accountEntropyPool {
            missingKeyGenerator.accountEntropyPool = { accountEntropyPool }
        } else {
            missingKeyGenerator.masterKey = { newMasterKey }
        }

        scheduler.tick()

        var nextStep: Guarantee<RegistrationStep>!

        // Submit a code at t=5.
        scheduler.run(atTime: 5) {
            nextStep = coordinator.submitVerificationCode(Stubs.pinCode)
        }

        // At t=7, give back a verified session.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: true
            )),
            atTime: 7
        )

        let accountIdentityResponse = Stubs.accountIdentityResponse()
        var authPassword: String!

        // That means at t=7 it should try and register with the verified
        // session; be ready for that starting at t=6 (but not before).

        // Before registering at t=7, it should ask for push tokens to give the registration.
        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 7)
            return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 8)
        }

        // It should also fetch the prekeys for account creation
        preKeyManagerMock.createPreKeysMock = {
            #expect(self.scheduler.currentTime == 8)
            return self.scheduler.promise(resolvingWith: Stubs.prekeyBundles(), atTime: 9)
        }

        scheduler.run(atTime: 8) {
            let expectedRequest = RegistrationRequestFactory.createAccountRequest(
                verificationMethod: .sessionId(Stubs.sessionId),
                e164: Stubs.e164,
                authPassword: "", // Doesn't matter for request generation.
                accountAttributes: Stubs.accountAttributes(newMasterKey),
                skipDeviceTransfer: true,
                apnRegistrationId: Stubs.apnsRegistrationId,
                prekeyBundles: Stubs.prekeyBundles()
            )
            // Resolve it at t=10
            self.mockURLSession.addResponse(
                TSRequestOWSURLSessionMock.Response(
                    matcher: { request in
                        authPassword = request.authPassword
                        let requestAttributes = Self.attributesFromCreateAccountRequest(request)
                        // These should be empty if sessionId is sent
                        #expect((request.parameters["recoveryPassword"] as? String) == nil)
                        #expect(requestAttributes.registrationRecoveryPassword == nil)
                        return request.url == expectedRequest.url
                    },
                    statusCode: 200,
                    bodyJson: accountIdentityResponse
                ),
                atTime: 10,
                on: self.scheduler
            )
        }

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: accountIdentityResponse.aci,
                pni: accountIdentityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // Once we are registered at t=10, we should finalize prekeys.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            #expect(self.scheduler.currentTime == 10)
            #expect(didSucceed)
            return self.scheduler.promise(resolvingWith: (), atTime: 11)
        }

        // Then we should try and create one time pre-keys
        // with the credentials we got in the identity response.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            #expect(self.scheduler.currentTime == 11)
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return self.scheduler.promise(resolvingWith: (), atTime: 12)
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 12)

        // Now we should ask to create a PIN.
        // No exit allowed since we've already started trying to create the account.
        #expect(nextStep.value == .pinEntry(
            Stubs.pinEntryStateForPostRegCreate(mode: mode, exitConfigOverride: .noExitAllowed)
        ))

        scheduler.adjustTime(to: 0)

        // Skip the PIN code.
        nextStep = coordinator.skipPINCode()

        // When we skip the pin, it should skip any SVR backups.
        svr.backupMasterKeyMock = { _, masterKey, _ in
            Issue.record("Shouldn't talk to SVR with skipped PIN!")
            return .value(masterKey)
        }
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { _, _ in
            return .value(())
        }

        // And at t=0 once we skip the storage service restore,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(newMasterKey),
            auth: .implicit() // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            matcher: { request in
                #expect(self.scheduler.currentTime == 0)
                return request.url == expectedAttributesRequest.url
            },
            statusCode: 200
        )

        // At this point we should have no master key.
        #expect(svr.hasMasterKey == false)
        #expect(svr.hasAccountEntropyPool == false)

        var didSetLocalAccountEntropyPool = false
        svr.useDeviceLocalAccountEntropyPoolMock = { _ in
            #expect(self.svr.hasAccountEntropyPool == false)
            didSetLocalAccountEntropyPool = true
        }

        var didSetLocalMasterKey = false
        svr.useDeviceLocalMasterKeyMock = { _ in
            #expect(self.svr.hasMasterKey == false)
            didSetLocalMasterKey = true
        }

        // Once we sync push tokens, we should restore from storage service.
        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            #expect(auth.authedAccount == expectedAuthedAccount())
            switch masterKeySource {
            case .explicit(let explicitMasterKey):
                #expect(newMasterKey.rawData == explicitMasterKey.rawData)
            default:
                Issue.record("Unexpected master key used in storage service operation.")
            }
            return .value(())
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 0)

        #expect(nextStep.value == .done)

        if testCase.newKey == .accountEntropyPool {
            #expect(didSetLocalAccountEntropyPool)
        } else {
            #expect(didSetLocalMasterKey)
        }

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    @MainActor
    @Test(arguments: Self.testCases())
    func testSessionPath_skipPINRestore_createNewPIN(testCase: TestCase) {
        let coordinator = setupTest(testCase)
        let mode = testCase.mode

        switch mode {
        case .registering:
            break
        case .reRegistering, .changingNumber:
            // Test only applies to registering scenarios.
            return
        }

        createSessionAndRequestFirstCode(coordinator: coordinator, mode: mode)

        let accountEntropyPool = AccountEntropyPool()
        let newMasterKey = accountEntropyPool.getMasterKey()
        if testCase.newKey == .accountEntropyPool {
            missingKeyGenerator.accountEntropyPool = { accountEntropyPool }
        } else {
            missingKeyGenerator.masterKey = { newMasterKey }
        }

        scheduler.tick()

        var nextStep: Guarantee<RegistrationStep>!

        // Submit a code at t=5.
        scheduler.run(atTime: 5) {
            nextStep = coordinator.submitVerificationCode(Stubs.pinCode)
        }

        // At t=7, give back a verified session.
        self.sessionManager.submitCodeResponse = self.scheduler.guarantee(
            resolvingWith: .success(RegistrationSession(
                id: Stubs.sessionId,
                e164: Stubs.e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: true
            )),
            atTime: 7
        )

        // Previously used SVR so we first ask to restore.
        let accountIdentityResponse = Stubs.accountIdentityResponse(hasPreviouslyUsedSVR: true)
        var authPassword: String!

        // That means at t=7 it should try and register with the verified
        // session; be ready for that starting at t=6 (but not before).

        // Before registering at t=7, it should ask for push tokens to give the registration.
        pushRegistrationManagerMock.requestPushTokenMock = {
            #expect(self.scheduler.currentTime == 7)
            return self.scheduler.guarantee(resolvingWith: .success(Stubs.apnsRegistrationId), atTime: 8)
        }

        // It should also fetch the prekeys for account creation
        preKeyManagerMock.createPreKeysMock = {
            #expect(self.scheduler.currentTime == 8)
            return self.scheduler.promise(resolvingWith: Stubs.prekeyBundles(), atTime: 9)
        }

        scheduler.run(atTime: 8) {
            let expectedRequest = RegistrationRequestFactory.createAccountRequest(
                verificationMethod: .sessionId(Stubs.sessionId),
                e164: Stubs.e164,
                authPassword: "", // Doesn't matter for request generation.
                accountAttributes: Stubs.accountAttributes(newMasterKey),
                skipDeviceTransfer: true,
                apnRegistrationId: Stubs.apnsRegistrationId,
                prekeyBundles: Stubs.prekeyBundles()
            )
            // Resolve it at t=10
            self.mockURLSession.addResponse(
                TSRequestOWSURLSessionMock.Response(
                    matcher: { request in
                        authPassword = request.authPassword
                        return request.url == expectedRequest.url
                    },
                    statusCode: 200,
                    bodyJson: accountIdentityResponse
                ),
                atTime: 10,
                on: self.scheduler
            )
        }

        func expectedAuthedAccount() -> AuthedAccount {
            return .explicit(
                aci: accountIdentityResponse.aci,
                pni: accountIdentityResponse.pni,
                e164: Stubs.e164,
                deviceId: .primary,
                authPassword: authPassword
            )
        }

        // Once we are registered at t=10, we should finalize prekeys.
        preKeyManagerMock.finalizePreKeysMock = { didSucceed in
            #expect(self.scheduler.currentTime == 10)
            #expect(didSucceed)
            return self.scheduler.promise(resolvingWith: (), atTime: 11)
        }

        // Then we should try and create one time pre-keys
        // with the credentials we got in the identity response.
        preKeyManagerMock.rotateOneTimePreKeysMock = { auth in
            #expect(self.scheduler.currentTime == 11)
            #expect(auth == expectedAuthedAccount().chatServiceAuth)
            return self.scheduler.promise(resolvingWith: (), atTime: 12)
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 12)

        // Now we should ask to restore the PIN.
        #expect(nextStep.value == .pinEntry(
            Stubs.pinEntryStateForPostRegRestore(mode: mode)
        ))

        scheduler.adjustTime(to: 0)

        // Skip the PIN code and create a new one instead.
        nextStep = coordinator.skipAndCreateNewPINCode()

        scheduler.runUntilIdle()

        // When we skip, we should be asked to _create_ the PIN.
        #expect(nextStep.value == .pinEntry(
            Stubs.pinEntryStateForPostRegCreate(mode: mode, exitConfigOverride: .noExitAllowed)
        ))

        // Skip this PIN code, too.
        nextStep = coordinator.skipPINCode()

        // When we skip the pin, it should skip any SVR backups.
        svr.backupMasterKeyMock = { _, masterKey, _ in
            Issue.record("Shouldn't talk to SVR with skipped PIN!")
            return .value(masterKey)

        }

        storageServiceManagerMock.restoreOrCreateManifestIfNecessaryMock = { auth, masterKeySource in
            #expect(auth.authedAccount == expectedAuthedAccount())
            switch masterKeySource {
            case .explicit(let explicitMasterKey):
                #expect(newMasterKey.rawData == explicitMasterKey.rawData)
            default:
                Issue.record("Unexpected master key used in storage service operation.")
            }
            return .value(())
        }

        // And at t=0 once we skip the storage service restore,
        // we will sync account attributes and then we are finished!
        let expectedAttributesRequest = RegistrationRequestFactory.updatePrimaryDeviceAccountAttributesRequest(
            Stubs.accountAttributes(newMasterKey),
            auth: .implicit() // doesn't matter for url matching
        )
        self.mockURLSession.addResponse(
            matcher: { request in
                #expect(self.scheduler.currentTime == 0)
                return request.url == expectedAttributesRequest.url
            },
            statusCode: 200
        )

        // At this point we should have no master key.
        #expect(svr.hasMasterKey.negated)

        var didSetLocalAccountEntropyPool = false
        svr.useDeviceLocalAccountEntropyPoolMock = { _ in
            #expect(self.svr.hasAccountEntropyPool == false)
            didSetLocalAccountEntropyPool = true
        }

        var didSetLocalMasterKey = false
        svr.useDeviceLocalMasterKeyMock = { _ in
            #expect(self.svr.hasMasterKey == false)
            didSetLocalMasterKey = true
        }

        scheduler.runUntilIdle()
        #expect(scheduler.currentTime == 0)

        #expect(nextStep.value == .done)

        if testCase.newKey == .accountEntropyPool {
            #expect(didSetLocalAccountEntropyPool)
        } else {
            #expect(didSetLocalMasterKey)
        }

        // Since we set profile info, we should have scheduled a reupload.
        #expect(profileManagerMock.didScheduleReuploadLocalProfile)
    }

    // MARK: - Profile Setup Path

    // TODO[Registration]: test the profile setup steps.

    // MARK: - Persisted State backwards compatibility

    typealias ReglockState = RegistrationCoordinatorImpl.PersistedState.SessionState.ReglockState

    @MainActor
    @Test
    func testPersistedState_SVRCredentialCompat() throws {
        let reglockExpirationDate = Date(timeIntervalSince1970: 10000)
        let decoder = JSONDecoder()

        // Serialized ReglockState.none
        let reglockStateNoneData = "7b226e6f6e65223a7b7d7d"
        #expect(
            try decoder.decode(ReglockState.self, from: Data.data(fromHex: reglockStateNoneData)!) ==
            ReglockState.none
        )

        // Serialized ReglockState.reglocked(
        //     credential: KBSAuthCredential(credential: RemoteAttestation.Auth(username: "abcd", password: "xyz"),
        //     expirationDate: reglockExpirationDate
        // )
        let reglockStateReglockedData = "7b227265676c6f636b6564223a7b2265787069726174696f6e44617465223a2d3937383239373230302c2263726564656e7469616c223a7b2263726564656e7469616c223a7b22757365726e616d65223a2261626364222c2270617373776f7264223a2278797a227d7d7d7d"
        #expect(
            try decoder.decode(ReglockState.self, from: Data.data(fromHex: reglockStateReglockedData)!) ==
            ReglockState.reglocked(credential: .testOnly(svr2: nil), expirationDate: reglockExpirationDate)
        )

        // Serialized ReglockState.reglocked(
        //     credential: ReglockState.SVRAuthCredential(
        //         kbs: KBSAuthCredential(credential: RemoteAttestation.Auth(username: "abcd", password: "xyz"),
        //         svr2: SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "xxx", password: "yyy"))
        //     ),
        //     expirationDate: reglockExpirationDate
        // )
        let reglockStateReglockedSVR2Data = "7b227265676c6f636b6564223a7b2265787069726174696f6e44617465223a2d3937383239373230302c2263726564656e7469616c223a7b226b6273223a7b2263726564656e7469616c223a7b22757365726e616d65223a2261626364222c2270617373776f7264223a2278797a227d7d2c2273767232223a7b2263726564656e7469616c223a7b22757365726e616d65223a22787878222c2270617373776f7264223a22797979227d7d7d7d7d"
        #expect(
            try decoder.decode(ReglockState.self, from: Data.data(fromHex: reglockStateReglockedSVR2Data)!) ==
            ReglockState.reglocked(credential: .init(svr2: Stubs.svr2AuthCredential), expirationDate: reglockExpirationDate)
        )

        // Serialized ReglockState.waitingTimeout(expirationDate: reglockExpirationDate)
        let reglockStateWaitingTimeoutData = "7b2277616974696e6754696d656f7574223a7b2265787069726174696f6e44617465223a2d3937383239373230307d7d"
        #expect(
            try decoder.decode(ReglockState.self, from: Data.data(fromHex: reglockStateWaitingTimeoutData)!) ==
            ReglockState.waitingTimeout(expirationDate: reglockExpirationDate)
        )
    }

    // MARK: Happy Path Setups

    private func preservingSchedulerState(_ block: () -> Void) {
        let startTime = scheduler.currentTime
        let wasRunning = scheduler.isRunning
        scheduler.stop()
        scheduler.adjustTime(to: 0)
        block()
        scheduler.adjustTime(to: startTime)
        if wasRunning {
            scheduler.start()
        }
    }

    private func goThroughOpeningHappyPath(
        coordinator: any RegistrationCoordinator,
        mode: RegistrationMode,
        expectedNextStep: RegistrationStep
    ) {
        preservingSchedulerState {
            contactsStore.doesNeedContactsAuthorization = true
            pushRegistrationManagerMock.doesNeedNotificationAuthorization = true

            var nextStep: Guarantee<RegistrationStep>!
            switch mode {
            case .registering:
                // Gotta get the splash out of the way.
                nextStep = coordinator.nextStep()
                scheduler.runUntilIdle()
                #expect(nextStep.value == .registrationSplash)
            case .reRegistering, .changingNumber:
                break
            }

            // Now we should show the permissions.
            nextStep = coordinator.continueFromSplash()
            scheduler.runUntilIdle()
            #expect(nextStep.value == .permissions)

            // Once the state is updated we can proceed.
            nextStep = coordinator.requestPermissions()
            scheduler.runUntilIdle()
            #expect(nextStep.value == expectedNextStep)
        }
    }

    private func setUpSessionPath(coordinator: any RegistrationCoordinator, mode: RegistrationMode) {
        // Set profile info so we skip those steps.
        self.setupDefaultAccountAttributes()

        pushRegistrationManagerMock.requestPushTokenMock = { .value(.success(Stubs.apnsRegistrationId)) }

        pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = { .pending().0 }

        // No other setup; no auth credentials, SVR keys, etc in storage
        // so that we immediately go to the session flow.

        // Get past the opening.
        goThroughOpeningHappyPath(
            coordinator: coordinator,
            mode: mode,
            expectedNextStep: .phoneNumberEntry(self.stubs.phoneNumberEntryState(mode: mode))
        )
    }

    private func createSessionAndRequestFirstCode(coordinator: any RegistrationCoordinator, mode: RegistrationMode) {
        setUpSessionPath(coordinator: coordinator, mode: mode)

        preservingSchedulerState {
            // Give it a phone number, which should cause it to start a session.
            let nextStep = coordinator.submitE164(Stubs.e164)

            // We'll ask for a push challenge, though we won't resolve it.
            self.pushRegistrationManagerMock.receivePreAuthChallengeTokenMock = {
                return Guarantee<String>.pending().0
            }

            // At t=2, give back a session that's ready to go.
            self.sessionManager.beginSessionResponse = self.scheduler.guarantee(
                resolvingWith: .success(RegistrationSession(
                    id: Stubs.sessionId,
                    e164: Stubs.e164,
                    receivedDate: self.date,
                    nextSMS: 0,
                    nextCall: 0,
                    nextVerificationAttempt: nil,
                    allowedToRequestCode: true,
                    requestedInformation: [],
                    hasUnknownChallengeRequiringAppUpdate: false,
                    verified: false
                )),
                atTime: 2
            )

            // Once we get that session at t=2, we should try and send a code.
            // Be ready for that starting at t=1 (but not before).
            scheduler.run(atTime: 1) {
                // Resolve with a session thats ready for code submission at time 3.
                self.sessionManager.requestCodeResponse = self.scheduler.guarantee(
                    resolvingWith: .success(RegistrationSession(
                        id: Stubs.sessionId,
                        e164: Stubs.e164,
                        receivedDate: self.date,
                        nextSMS: 0,
                        nextCall: 0,
                        nextVerificationAttempt: 0,
                        allowedToRequestCode: true,
                        requestedInformation: [],
                        hasUnknownChallengeRequiringAppUpdate: false,
                        verified: false
                    )),
                    atTime: 3
                )
            }

            // At t=3 we should get back the code entry step.
            scheduler.runUntilIdle()
            #expect(scheduler.currentTime == 3)
            #expect(nextStep.value == .verificationCodeEntry(self.stubs.verificationCodeEntryState(mode: mode)))
        }
    }

    // MARK: - Helpers

    private func setupDefaultAccountAttributes() {
        ows2FAManagerMock.pinCodeMock = { nil }
        ows2FAManagerMock.isReglockEnabledMock = { false }

        tsAccountManagerMock.isManualMessageFetchEnabledMock = { false }

        setAllProfileInfo()
    }

    private func setAllProfileInfo() {
        phoneNumberDiscoverabilityManagerMock.phoneNumberDiscoverabilityMock = { .everybody }
        profileManagerMock.localUserProfileMock = { _ in
            return OWSUserProfile(
                id: nil,
                uniqueId: "00000000-0000-4000-8000-000000000000",
                serviceIdString: nil,
                phoneNumber: nil,
                avatarFileName: nil,
                avatarUrlPath: nil,
                profileKey: Aes256Key(data: Data(count: 32))!,
                givenName: "Johnny",
                familyName: "McJohnface",
                bio: nil,
                bioEmoji: nil,
                badges: [],
                lastFetchDate: Date(timeIntervalSince1970: 1735689600),
                lastMessagingDate: nil,
                isPhoneNumberShared: false
            )
        }
    }

    private static func attributesFromCreateAccountRequest(
        _ request: TSRequest
    ) -> AccountAttributes {
        let accountAttributesData = try! JSONSerialization.data(
            withJSONObject: request.parameters["accountAttributes"]!,
            options: .fragmentsAllowed
        )
        return try! JSONDecoder().decode(
            AccountAttributes.self,
            from: accountAttributesData
        )
    }

    // MARK: - Helpers

    func buildKeyDataMocks(_ testCase: TestCase) -> (MasterKey, MasterKey) {
        let newAccountEntropyPool = AccountEntropyPool()
        let newMasterKey = newAccountEntropyPool.getMasterKey()
        let oldAccountEntropyPool = AccountEntropyPool()
        let oldMasterKey = oldAccountEntropyPool.getMasterKey()
        switch (testCase.oldKey, testCase.newKey) {
        case (.accountEntropyPool, .accountEntropyPool):
            // on re-registration, make the AEP be present
            db.write { accountKeyStore.setAccountEntropyPool(oldAccountEntropyPool, tx: $0) }
            return (oldMasterKey, oldMasterKey)
        case (.masterKey, .masterKey):
            db.write { accountKeyStore.setMasterKey(oldMasterKey, tx: $0) }
            return (oldMasterKey, oldMasterKey)
        case (.masterKey, .accountEntropyPool):
            // If this is a reregistration from an non-AEP client,
            // AEP is only available after calling getOrGenerateAEP()
            db.write { accountKeyStore.setMasterKey(oldMasterKey, tx: $0) }
            missingKeyGenerator.accountEntropyPool = {
                return newAccountEntropyPool
            }
            return (oldMasterKey, newMasterKey)
        case (.none, .masterKey):
            missingKeyGenerator.masterKey = { newMasterKey }
            return (newMasterKey, newMasterKey)
        case (.none, .accountEntropyPool):
            missingKeyGenerator.accountEntropyPool = {
                newAccountEntropyPool
            }
            return (newMasterKey, newMasterKey)
        case (.accountEntropyPool, .masterKey):
            fatalError("Migrating to masterkey from AEP not supported")
        case (_, .none):
            fatalError("Registration requires a destination key")
        }
    }

    // MARK: - Stubs

    private struct Stubs {

        static let e164 = E164("+17875550100")!
        static let aci = Aci.randomForTesting()
        static let pinCode = "1234"

        static let svr2AuthCredential = SVR2AuthCredential(credential: RemoteAttestation.Auth(username: "xxx", password: "yyy"))

        static let captchaToken = "captchaToken"
        static let apnsToken = "apnsToken"
        static let apnsRegistrationId = RegistrationRequestFactory.ApnRegistrationId(apnsToken: Stubs.apnsToken)

        static let authUsername = "username_jdhfsalkjfhd"
        static let authPassword = "password_dskafjasldkfjasf"

        static let sessionId = UUID().uuidString
        static let verificationCode = "8888"

        var date: Date = Date()

        static func accountAttributes(_ masterKey: MasterKey? = nil) -> AccountAttributes {
            return AccountAttributes(
                isManualMessageFetchEnabled: false,
                registrationId: 0,
                pniRegistrationId: 0,
                unidentifiedAccessKey: "",
                unrestrictedUnidentifiedAccess: false,
                twofaMode: .none,
                registrationRecoveryPassword: masterKey?.regRecoveryPw,
                encryptedDeviceName: nil,
                discoverableByPhoneNumber: .nobody,
                hasSVRBackups: true
            )
        }

        static func accountIdentityResponse(
            hasPreviouslyUsedSVR: Bool = false
        ) -> RegistrationServiceResponses.AccountIdentityResponse {
            return RegistrationServiceResponses.AccountIdentityResponse(
                aci: Stubs.aci,
                pni: Pni.randomForTesting(),
                e164: Stubs.e164,
                username: nil,
                hasPreviouslyUsedSVR: hasPreviouslyUsedSVR
            )
        }

        func session(
            e164: E164 = Stubs.e164,
            hasSentVerificationCode: Bool
        ) -> RegistrationSession {
            return RegistrationSession(
                id: UUID().uuidString,
                e164: e164,
                receivedDate: self.date,
                nextSMS: 0,
                nextCall: 0,
                nextVerificationAttempt: hasSentVerificationCode ? 0 : nil,
                allowedToRequestCode: true,
                requestedInformation: [],
                hasUnknownChallengeRequiringAppUpdate: false,
                verified: false
            )
        }

        static func prekeyBundles() -> RegistrationPreKeyUploadBundles {
            return RegistrationPreKeyUploadBundles(
                aci: preKeyBundle(identity: .aci),
                pni: preKeyBundle(identity: .pni)
            )
        }

        static func preKeyBundle(identity: OWSIdentity) -> RegistrationPreKeyUploadBundle {
            let identityKeyPair = ECKeyPair.generateKeyPair()
            return RegistrationPreKeyUploadBundle(
                identity: identity,
                identityKeyPair: identityKeyPair,
                signedPreKey: SSKSignedPreKeyStore.generateSignedPreKey(signedBy: identityKeyPair),
                lastResortPreKey: {
                    let keyPair = KEMKeyPair.generate()
                    let signature = Data(identityKeyPair.keyPair.privateKey.generateSignature(message: Data(keyPair.publicKey.serialize())))

                    let record = SignalServiceKit.KyberPreKeyRecord(
                        0,
                        keyPair: keyPair,
                        signature: signature,
                        generatedAt: Date(),
                        isLastResort: true
                    )
                    return record
                }()
            )
        }

        // MARK: Step States

        static func pinEntryStateForRegRecoveryPath(
            mode: RegistrationMode,
            error: RegistrationPinValidationError? = nil,
            remainingAttempts: UInt? = nil
        ) -> RegistrationPinState {
            return RegistrationPinState(
                operation: .enteringExistingPin(
                    skippability: .canSkip,
                    remainingAttempts: remainingAttempts
                ),
                error: error,
                contactSupportMode: .v2WithUnknownReglockState,
                exitConfiguration: mode.pinExitConfig
            )
        }

        static func pinEntryStateForSVRAuthCredentialPath(
            mode: RegistrationMode,
            error: RegistrationPinValidationError? = nil
        ) -> RegistrationPinState {
            return RegistrationPinState(
                operation: .enteringExistingPin(skippability: .canSkip, remainingAttempts: nil),
                error: error,
                contactSupportMode: .v2WithUnknownReglockState,
                exitConfiguration: mode.pinExitConfig
            )
        }

        func phoneNumberEntryState(
            mode: RegistrationMode,
            previouslyEnteredE164: E164? = nil,
            withValidationErrorFor response: Registration.BeginSessionResponse? = nil
        ) -> RegistrationPhoneNumberViewState {
            let response = response ?? .success(self.session(hasSentVerificationCode: false))
            let validationError: RegistrationPhoneNumberViewState.ValidationError?
            switch response {
            case .success:
                validationError = nil
            case .invalidArgument:
                validationError = .invalidE164(.init(invalidE164: previouslyEnteredE164 ?? Stubs.e164))
            case .retryAfter(let timeInterval):
                validationError = .rateLimited(.init(
                    expiration: self.date.addingTimeInterval(timeInterval),
                    e164: previouslyEnteredE164 ?? Stubs.e164
                ))
            case .networkFailure, .genericError:
                Issue.record("Should not be generating phone number state for error responses.")
                validationError = nil
            }

            switch mode {
            case .registering:
                return .registration(.initialRegistration(.init(
                    previouslyEnteredE164: previouslyEnteredE164,
                    validationError: validationError,
                    canExitRegistration: true
                )))
            case .reRegistering(let params):
                return .registration(.reregistration(.init(
                    e164: params.e164,
                    validationError: validationError,
                    canExitRegistration: true
                )))
            case .changingNumber(let changeNumberParams):
                switch validationError {
                case .none:
                    if let newE164 = previouslyEnteredE164 {
                        return .changingNumber(.confirmation(.init(
                            oldE164: changeNumberParams.oldE164,
                            newE164: newE164,
                            rateLimitedError: nil
                        )))
                    } else {
                        return .changingNumber(.initialEntry(.init(
                            oldE164: changeNumberParams.oldE164,
                            newE164: nil,
                            hasConfirmed: false,
                            invalidE164Error: nil
                        )))
                    }
                case .rateLimited(let error):
                    return .changingNumber(.confirmation(.init(
                        oldE164: changeNumberParams.oldE164,
                        newE164: previouslyEnteredE164!,
                        rateLimitedError: error
                    )))
                case .invalidInput:
                    owsFail("Can't happen.")
                case .invalidE164(let error):
                    return .changingNumber(.initialEntry(.init(
                        oldE164: changeNumberParams.oldE164,
                        newE164: previouslyEnteredE164,
                        hasConfirmed: previouslyEnteredE164 != nil,
                        invalidE164Error: error
                    )))
                }
            }
        }

        func verificationCodeEntryState(
            mode: RegistrationMode,
            e164: E164 = Stubs.e164,
            nextSMS: TimeInterval? = 0,
            nextCall: TimeInterval? = 0,
            showHelpText: Bool = false,
            nextVerificationAttempt: TimeInterval? = 0,
            validationError: RegistrationVerificationValidationError? = nil,
            exitConfigOverride: RegistrationVerificationState.ExitConfiguration? = nil
        ) -> RegistrationVerificationState {

            let canChangeE164: Bool
            switch mode {
            case .reRegistering:
                canChangeE164 = false
            case .registering, .changingNumber:
                canChangeE164 = true
            }

            return RegistrationVerificationState(
                e164: e164,
                nextSMSDate: nextSMS.map { date.addingTimeInterval($0) },
                nextCallDate: nextCall.map { date.addingTimeInterval($0) },
                nextVerificationAttemptDate: nextVerificationAttempt.map { date.addingTimeInterval($0) },
                canChangeE164: canChangeE164,
                showHelpText: showHelpText,
                validationError: validationError,
                exitConfiguration: exitConfigOverride ?? mode.verificationExitConfig
            )
        }

        static func pinEntryStateForSessionPathReglock(
            mode: RegistrationMode,
            error: RegistrationPinValidationError? = nil
        ) -> RegistrationPinState {
            return RegistrationPinState(
                operation: .enteringExistingPin(skippability: .unskippable, remainingAttempts: nil),
                error: error,
                contactSupportMode: .v2WithReglock,
                exitConfiguration: mode.pinExitConfig
            )
        }

        static func pinEntryStateForPostRegRestore(
            mode: RegistrationMode,
            exitConfigOverride: RegistrationPinState.ExitConfiguration? = nil,
            error: RegistrationPinValidationError? = nil
        ) -> RegistrationPinState {
            return RegistrationPinState(
                operation: .enteringExistingPin(
                    skippability: .canSkipAndCreateNew,
                    remainingAttempts: nil
                ),
                error: error,
                contactSupportMode: .v2NoReglock,
                exitConfiguration: exitConfigOverride ?? mode.pinExitConfig
            )
        }

        static func pinEntryStateForPostRegCreate(
            mode: RegistrationMode,
            exitConfigOverride: RegistrationPinState.ExitConfiguration? = nil
        ) -> RegistrationPinState {
            return RegistrationPinState(
                operation: .creatingNewPin,
                error: nil,
                contactSupportMode: .v2NoReglock,
                exitConfiguration: exitConfigOverride ?? mode.pinExitConfig
            )
        }

        static func pinEntryStateForPostRegConfirm(
            mode: RegistrationMode,
            error: RegistrationPinValidationError? = nil,
            exitConfigOverride: RegistrationPinState.ExitConfiguration? = nil
        ) -> RegistrationPinState {
            return RegistrationPinState(
                operation: .confirmingNewPin(.stub()),
                error: error,
                contactSupportMode: .v2NoReglock,
                exitConfiguration: exitConfigOverride ?? mode.pinExitConfig
            )
        }
    }
}

extension RegistrationMode {

    var testDescription: String {
        switch self {
        case .registering:
            return "registering"
        case .reRegistering:
            return "re-registering"
        case .changingNumber:
            return "changing number"
        }
    }

    var pinExitConfig: RegistrationPinState.ExitConfiguration {
        switch self {
        case .registering:
            return .noExitAllowed
        case .reRegistering:
            return .exitReRegistration
        case .changingNumber:
            // TODO[Registration]: test change number properly
            return .exitChangeNumber
        }
    }

    var verificationExitConfig: RegistrationVerificationState.ExitConfiguration {
        switch self {
        case .registering:
            return .noExitAllowed
        case .reRegistering:
            return .exitReRegistration
        case .changingNumber:
            // TODO[Registration]: test change number properly
            return .exitChangeNumber
        }
    }
}

private extension MasterKey {
    var regRecoveryPw: String { data(for: .registrationRecoveryPassword).rawData.base64EncodedString() }
    var reglockToken: String { data(for: .registrationLock).rawData.hexadecimalString }
}

private class PreKeyError: Error {
    init() {}
}

struct EncodableRegistrationLockFailureResponse: Codable {
    typealias ResponseType = RegistrationServiceResponses.RegistrationLockFailureResponse
    typealias CodingKeys = ResponseType.CodingKeys

    var response: ResponseType

    init(from decoder: any Decoder) throws {
        response = try ResponseType(from: decoder)
    }

    init(timeRemainingMs: Int, svr2AuthCredential: SVR2AuthCredential) {
        self.response = ResponseType(timeRemainingMs: timeRemainingMs, svr2AuthCredential: svr2AuthCredential)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(response.timeRemainingMs, forKey: .timeRemainingMs)
        try container.encodeIfPresent(response.svr2AuthCredential.credential, forKey: .svr2AuthCredential)
    }
}

private extension Usernames.UsernameLink {
    static var mocked: Usernames.UsernameLink {
        return Usernames.UsernameLink(
            handle: UUID(),
            entropy: Data(repeating: 8, count: 32)
        )!
    }
}

private extension TSRequest {
    var authPassword: String {
        var httpHeaders = HttpHeaders()
        self.applyAuth(to: &httpHeaders, willSendViaWebSocket: false)
        let authHeader = httpHeaders.value(forHeader: "Authorization")!
        owsPrecondition(authHeader.hasPrefix("Basic "))
        let authValue = String(data: Data(base64Encoded: String(authHeader.dropFirst(6)))!, encoding: .utf8)!
        return String(authValue.split(separator: ":").dropFirst().first!)
    }
}
