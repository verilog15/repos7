//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import XCTest
import LibSignalClient

@testable import Signal
@testable import SignalServiceKit

public class ProvisioningCoordinatorTest: XCTestCase {

    typealias Mocks = ProvisioningCoordinatorImpl.Mocks

    private var provisioningCoordinator: ProvisioningCoordinatorImpl!

    private var chatConnectionManagerMock: ChatConnectionManagerMock!
    private var identityManagerMock: MockIdentityManager!
    private var accountKeyStore: AccountKeyStore!
    private var messageFactoryMock: Mocks.MessageFactory!
    private var prekeyManagerMock: MockPreKeyManager!
    private var profileManagerMock: Mocks.ProfileManager!
    private var pushRegistrationManagerMock: Mocks.PushRegistrationManager!
    private var receiptManagerMock: Mocks.ReceiptManager!
    private var registrationStateChangeManagerMock: MockRegistrationStateChangeManager!
    private var signalServiceMock: OWSSignalServiceMock!
    private var storageServiceManagerMock: FakeStorageServiceManager!
    private var svrMock: SecureValueRecoveryMock!
    private var syncManagerMock: Mocks.SyncManager!
    private var threadStoreMock: MockThreadStore!
    private var tsAccountManagerMock: MockTSAccountManager!
    private var udManagerMock: Mocks.UDManager!

    public override func setUp() async throws {

        let mockDb = InMemoryDB()

        let recipientDbTable = MockRecipientDatabaseTable()
        let recipientFetcher = RecipientFetcherImpl(recipientDatabaseTable: recipientDbTable)
        let recipientIdFinder = RecipientIdFinder(
            recipientDatabaseTable: recipientDbTable,
            recipientFetcher: recipientFetcher
        )
        self.identityManagerMock = .init(recipientIdFinder: recipientIdFinder)

        self.chatConnectionManagerMock = .init()
        self.accountKeyStore = .init()
        self.messageFactoryMock = .init()
        self.prekeyManagerMock = .init()
        self.profileManagerMock = .init()
        self.pushRegistrationManagerMock = .init()
        self.receiptManagerMock = .init()
        self.registrationStateChangeManagerMock = .init()
        self.signalServiceMock = .init()
        self.storageServiceManagerMock = .init()
        self.svrMock = .init()
        self.syncManagerMock = .init()
        self.threadStoreMock = .init()
        self.tsAccountManagerMock = .init()
        self.udManagerMock = .init()

        self.provisioningCoordinator = ProvisioningCoordinatorImpl(
            chatConnectionManager: chatConnectionManagerMock,
            db: mockDb,
            deviceService: MockOWSDeviceService(),
            identityManager: identityManagerMock,
            linkAndSyncManager: MockLinkAndSyncManager(),
            accountKeyStore: accountKeyStore,
            messageFactory: messageFactoryMock,
            preKeyManager: prekeyManagerMock,
            profileManager: profileManagerMock,
            pushRegistrationManager: pushRegistrationManagerMock,
            receiptManager: receiptManagerMock,
            registrationStateChangeManager: registrationStateChangeManagerMock,
            signalProtocolStoreManager: MockSignalProtocolStoreManager(),
            signalService: signalServiceMock,
            storageServiceManager: storageServiceManagerMock,
            svr: svrMock,
            syncManager: syncManagerMock,
            threadStore: threadStoreMock,
            tsAccountManager: tsAccountManagerMock,
            udManager: udManagerMock
        )

        tsAccountManagerMock.registrationStateMock = { .unregistered }
    }

    public func testProvisioning() async throws {
        let aep = AccountEntropyPool()
        let provisioningMessage = LinkingProvisioningMessage(
            rootKey: .accountEntropyPool(aep),
            aci: .randomForTesting(),
            phoneNumber: "+17875550100",
            pni: .randomForTesting(),
            aciIdentityKeyPair: IdentityKeyPair.generate(),
            pniIdentityKeyPair: IdentityKeyPair.generate(),
            profileKey: .generateRandom(),
            mrbk: BackupKey.forTesting(),
            ephemeralBackupKey: nil,
            areReadReceiptsEnabled: true,
            provisioningCode: "1234"
        )
        let deviceName = "test device"
        let deviceId = DeviceId(validating: UInt32.random(in: 2...3))!

        let mockSession = UrlSessionMock()

        let verificationResponse = ProvisioningServiceResponses.VerifySecondaryDeviceResponse(
            pni: provisioningMessage.pni,
            deviceId: deviceId
        )

        mockSession.responder = { request in
            if request.url!.absoluteString.hasSuffix("v1/devices/link") {
                return try! JSONEncoder().encode(verificationResponse)
            } else if request.url!.absoluteString.hasSuffix("v1/devices/capabilities") {
                return Data()
            } else {
                XCTFail("Unexpected request!")
                return Data()
            }
        }

        signalServiceMock.mockUrlSessionBuilder = { (signalServiceInfo, _, _) in
            XCTAssertEqual(
                signalServiceInfo.baseUrl,
                SignalServiceType.mainSignalServiceIdentified.signalServiceInfo().baseUrl
            )
            return mockSession
        }

        pushRegistrationManagerMock.mockRegistrationId = .init(apnsToken: "apn")

        var didSetLocalIdentifiers = false
        registrationStateChangeManagerMock.didProvisionSecondaryMock = { e164, aci, pni, _, storedDeviceId in
            XCTAssertEqual(e164.stringValue, provisioningMessage.phoneNumber)
            XCTAssertEqual(aci, provisioningMessage.aci)
            XCTAssertEqual(pni, provisioningMessage.pni)
            XCTAssertEqual(storedDeviceId, deviceId)
            didSetLocalIdentifiers = true
        }

        try await provisioningCoordinator.completeProvisioning(
            provisionMessage: provisioningMessage,
            deviceName: deviceName,
            progressViewModel: LinkAndSyncSecondaryProgressViewModel()
        )

        XCTAssert(didSetLocalIdentifiers)
        XCTAssert(prekeyManagerMock.didFinalizeRegistrationPrekeys)
        XCTAssertEqual(
            profileManagerMock.localUserProfileMock?.profileKey,
            provisioningMessage.profileKey
        )
        XCTAssertEqual(
            identityManagerMock.identityKeyPairs[.aci]?.publicKey,
            provisioningMessage.aciIdentityKeyPair.asECKeyPair.publicKey
        )
        XCTAssertEqual(
            identityManagerMock.identityKeyPairs[.pni]?.publicKey,
            provisioningMessage.pniIdentityKeyPair.asECKeyPair.publicKey
        )
        let masterKey = switch provisioningMessage.rootKey {
        case .accountEntropyPool(let accountEntropyPool):
            accountEntropyPool.getMasterKey()
        case .masterKey(let masterKey):
            masterKey
        }
        XCTAssertEqual(svrMock.syncedMasterKey?.rawData, masterKey.rawData)
    }

    private func keyPairForTesting() throws -> ECKeyPair {
        let privateKey = try PrivateKey(Array(repeating: 0, count: 31) + [.random(in: 0..<0x48)])
        return ECKeyPair(IdentityKeyPair(publicKey: privateKey.publicKey, privateKey: privateKey))
    }
}

extension ProvisioningCoordinatorTest {

    class UrlSessionMock: BaseOWSURLSessionMock {

        var responder: ((TSRequest) -> Data)?

        override func performRequest(_ rawRequest: TSRequest) async throws -> any HTTPResponse {
            let responseBody = responder!(rawRequest)
            return HTTPResponseImpl(
                requestUrl: rawRequest.url!,
                status: 200,
                headers: HttpHeaders(),
                bodyData: responseBody
            )
        }
    }
}

private class MockLinkAndSyncManager: LinkAndSyncManager {

    func isLinkAndSyncEnabledOnPrimary(tx: DBReadTransaction) -> Bool {
        true
    }

    func setIsLinkAndSyncEnabledOnPrimary(_ isEnabled: Bool, tx: DBWriteTransaction) {}

    func generateEphemeralBackupKey() -> BackupKey {
        return .forTesting()
    }

    func waitForLinkingAndUploadBackup(
        ephemeralBackupKey: BackupKey,
        tokenId: DeviceProvisioningTokenId,
        progress: OWSProgressSink
    ) async throws(PrimaryLinkNSyncError) {
        return
    }

    func waitForBackupAndRestore(
        localIdentifiers: LocalIdentifiers,
        auth: ChatServiceAuth,
        ephemeralBackupKey: BackupKey,
        progress: OWSProgressSink
    ) async throws(SecondaryLinkNSyncError) {
        return
    }
}

private class MockOWSDeviceService: OWSDeviceService {

    init() {}

    func refreshDevices() async throws -> Bool {
        return true
    }

    func renameDevice(device: SignalServiceKit.OWSDevice, toEncryptedName encryptedName: String) async throws {
        // do nothing
    }

    func unlinkDevice(deviceId: DeviceId, auth: SignalServiceKit.ChatServiceAuth) async throws {
        // do nothing
    }
}

private class MockSignalProtocolStoreManager: SignalProtocolStoreManager {

    init() {}

    func signalProtocolStore(for identity: SignalServiceKit.OWSIdentity) -> any SignalServiceKit.SignalProtocolStore {
        return MockSignalProtocolStore()
    }

    func removeAllKeys(tx: DBWriteTransaction) {}
}
