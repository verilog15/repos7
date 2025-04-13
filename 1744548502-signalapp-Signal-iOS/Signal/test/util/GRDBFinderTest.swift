//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import LibSignalClient
import XCTest

@testable import SignalServiceKit
@testable import Signal

class GRDBFinderTest: SignalBaseTest {
    override func setUp() {
        super.setUp()

        SSKEnvironment.shared.databaseStorageRef.write { tx in
            (DependenciesBridge.shared.registrationStateChangeManager as! RegistrationStateChangeManagerImpl).registerForTests(
                localIdentifiers: .forUnitTests,
                tx: tx
            )
        }
    }

    func testThreadFinder() {

        // Contact Threads
        let address1 = SignalServiceAddress(phoneNumber: "+16505550101")
        let address2 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550102")
        let address3 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550103")
        let address4 = SignalServiceAddress.randomForTesting()
        let address5 = SignalServiceAddress(phoneNumber: "+16505550105")
        let address6 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550106")
        let address7 = SignalServiceAddress.randomForTesting()
        let contactThread1 = TSContactThread(contactAddress: address1)
        let contactThread2 = TSContactThread(contactAddress: address2)
        let contactThread3 = TSContactThread(contactAddress: address3)
        let contactThread4 = TSContactThread(contactAddress: address4)
        // Group Threads
        let createGroupThread: () -> TSGroupThread = {
            var groupThread: TSGroupThread!
            self.write { transaction in
                groupThread = try! GroupManager.createGroupForTests(members: [address1], name: "Test Group", transaction: transaction)
            }
            return groupThread
        }

        self.read { tx in
            XCTAssertNil(ContactThreadFinder().contactThread(for: address1, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address2, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address3, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address4, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address5, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address6, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address7, tx: tx))
        }

        _ = createGroupThread()
        _ = createGroupThread()
        _ = createGroupThread()
        _ = createGroupThread()

        self.write { transaction in
            contactThread1.anyInsert(transaction: transaction)
            contactThread2.anyInsert(transaction: transaction)
            contactThread3.anyInsert(transaction: transaction)
            contactThread4.anyInsert(transaction: transaction)
        }

        self.read { tx in
            XCTAssertNotNil(ContactThreadFinder().contactThread(for: address1, tx: tx))
            XCTAssertNotNil(ContactThreadFinder().contactThread(for: address2, tx: tx))
            XCTAssertNotNil(ContactThreadFinder().contactThread(for: address3, tx: tx))
            XCTAssertNotNil(ContactThreadFinder().contactThread(for: address4, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address5, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address6, tx: tx))
            XCTAssertNil(ContactThreadFinder().contactThread(for: address7, tx: tx))
        }
    }

    func testSignalAccountFinder() {

        // We'll create SignalAccount for these...
        let address1 = SignalServiceAddress(phoneNumber: "+16505550101")
        let address2 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550102")
        let address3 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550103")
        let address4 = SignalServiceAddress.randomForTesting()
        // ...but not these.
        let address5 = SignalServiceAddress(phoneNumber: "+16505550105")
        let address6 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550106")
        let address7 = SignalServiceAddress.randomForTesting()

        self.write { transaction in
            SignalAccount(address: address1).anyInsert(transaction: transaction)
            SignalAccount(address: address2).anyInsert(transaction: transaction)
            SignalAccount(address: address3).anyInsert(transaction: transaction)
            SignalAccount(address: address4).anyInsert(transaction: transaction)
        }

        self.read { tx in
            // These should exist...
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: address1, tx: tx))
            // If we save a SignalAccount with just a phone number,
            // we should later be able to look it up using a UUID & phone number,
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: address1.phoneNumber!), tx: tx))
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: address2, tx: tx))
            // If we save a SignalAccount with just a phone number and UUID,
            // we should later be able to look it up using just a UUID.
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(address2.serviceId!), tx: tx))
            // If we save a SignalAccount with just a phone number and UUID,
            // we should later be able to look it up using just a phone number.
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(phoneNumber: address2.phoneNumber!), tx: tx))
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: address3, tx: tx))
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(address3.serviceId!), tx: tx))
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(phoneNumber: address3.phoneNumber!), tx: tx))
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: address4, tx: tx))
            // If we save a SignalAccount with just a UUID,
            // we should later be able to look it up using a UUID & phone number,
            XCTAssertNotNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(serviceId: address4.serviceId!, phoneNumber: "+16505550198"), tx: tx))

            // ...these don't.
            XCTAssertNil(SignalAccountFinder().signalAccount(for: address5, tx: tx))
            XCTAssertNil(SignalAccountFinder().signalAccount(for: address6, tx: tx))
            XCTAssertNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(address6.serviceId!), tx: tx))
            XCTAssertNil(SignalAccountFinder().signalAccount(for: SignalServiceAddress(phoneNumber: address6.phoneNumber!), tx: tx))
            XCTAssertNil(SignalAccountFinder().signalAccount(for: address7, tx: tx))
        }
    }

    func testSignalRecipientFinder() {

        // We'll create SignalRecipient for these...
        let address1 = SignalServiceAddress(phoneNumber: "+16505550101")
        let address2 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550102")
        let address3 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550103")
        let address4 = SignalServiceAddress.randomForTesting()
        // ...but not these.
        let address5 = SignalServiceAddress(phoneNumber: "+16505550105")
        let address6 = SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: "+16505550106")
        let address7 = SignalServiceAddress.randomForTesting()

        self.write { transaction in
            [address1, address2, address3, address4].forEach {
                SignalRecipient(aci: $0.aci, pni: nil, phoneNumber: $0.e164)
                    .anyInsert(transaction: transaction)
            }
        }

        /// We used to have a type called `SignalRecipientFinder`, whose
        /// functionality was moved to `RecipientDatabaseTable`. To minimize the
        /// diff in the code just below, I've recreated a type with the same
        /// name such that the lines below didn't need to change.
        struct SignalRecipientFinder {
            func signalRecipient(for address: SignalServiceAddress, tx: DBReadTransaction) -> SignalRecipient? {
                return DependenciesBridge.shared.recipientDatabaseTable
                    .fetchRecipient(address: address, tx: tx)
            }
        }

        self.read { tx in
            // These should exist...
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: address1, tx: tx))
            // If we save a SignalRecipient with just a phone number,
            // we should later be able to look it up using a UUID & phone number,
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(serviceId: Aci.randomForTesting(), phoneNumber: address1.phoneNumber!), tx: tx))
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: address2, tx: tx))
            // If we save a SignalRecipient with just a phone number and UUID,
            // we should later be able to look it up using just a UUID.
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(address2.serviceId!), tx: tx))
            // If we save a SignalRecipient with just a phone number and UUID,
            // we should later be able to look it up using just a phone number.
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(phoneNumber: address2.phoneNumber!), tx: tx))
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: address3, tx: tx))
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(address3.serviceId!), tx: tx))
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(phoneNumber: address3.phoneNumber!), tx: tx))
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: address4, tx: tx))
            // If we save a SignalRecipient with just a UUID,
            // we should later be able to look it up using a UUID & phone number,
            XCTAssertNotNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(serviceId: address4.serviceId!, phoneNumber: "+16505550198"), tx: tx))

            // ...these don't.
            XCTAssertNil(SignalRecipientFinder().signalRecipient(for: address5, tx: tx))
            XCTAssertNil(SignalRecipientFinder().signalRecipient(for: address6, tx: tx))
            XCTAssertNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(address6.serviceId!), tx: tx))
            XCTAssertNil(SignalRecipientFinder().signalRecipient(for: SignalServiceAddress(phoneNumber: address6.phoneNumber!), tx: tx))
            XCTAssertNil(SignalRecipientFinder().signalRecipient(for: address7, tx: tx))
        }
    }

    func testUserProfileFinder_missingAndStaleUserProfiles() {
        let now = Date()

        let dateWithOffsetFromNow = { (offset: TimeInterval) -> Date in
            return Date(timeInterval: offset, since: now)
        }

        var expectedAddresses = Set<OWSUserProfile.Address>()
        self.write { tx in
            let buildUserProfile = { () -> OWSUserProfile in
                return OWSUserProfile.getOrBuildUserProfile(
                    for: .otherUser(Aci.randomForTesting()),
                    userProfileWriter: .tests,
                    tx: tx
                )
            }

            func updateUserProfile(
                _ userProfile: OWSUserProfile,
                lastFetchDate: OptionalChange<Date> = .noChange,
                lastMessagingDate: OptionalChange<Date> = .noChange
            ) {
                userProfile.update(
                    lastFetchDate: lastFetchDate,
                    lastMessagingDate: lastMessagingDate,
                    userProfileWriter: .metadataUpdate,
                    transaction: tx
                )
            }

            do {
                // This profile is _not_ expected; lastMessagingDate is nil.
                _ = buildUserProfile()
            }

            do {
                // This profile is _not_ expected; lastMessagingDate is nil.
                let userProfile = buildUserProfile()
                updateUserProfile(userProfile, lastFetchDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.month)))
            }

            do {
                // This profile is _not_ expected; lastMessagingDate is nil.
                let userProfile = buildUserProfile()
                updateUserProfile(userProfile, lastFetchDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.minute)))
            }

            do {
                // This profile is _not_ expected; lastMessagingDate is old.
                let userProfile = buildUserProfile()
                updateUserProfile(userProfile, lastMessagingDate: .setTo(dateWithOffsetFromNow(-2 * TimeInterval.month)))
            }

            do {
                // This profile is _not_ expected; lastMessagingDate is old.
                let userProfile = buildUserProfile()
                updateUserProfile(
                    userProfile,
                    lastFetchDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.month)),
                    lastMessagingDate: .setTo(dateWithOffsetFromNow(-2 * TimeInterval.month))
                )
            }

            do {
                // This profile is _not_ expected; lastMessagingDate is old.
                let userProfile = buildUserProfile()
                updateUserProfile(
                    userProfile,
                    lastFetchDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.minute)),
                    lastMessagingDate: .setTo(dateWithOffsetFromNow(-2 * TimeInterval.month))
                )
            }

            do {
                // This profile is expected; lastMessagingDate is recent and lastFetchDate is nil.
                let userProfile = buildUserProfile()
                updateUserProfile(userProfile, lastMessagingDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.hour)))
                expectedAddresses.insert(userProfile.internalAddress)
            }

            do {
                // This profile is expected; lastMessagingDate is recent and lastFetchDate is old.
                let userProfile = buildUserProfile()
                updateUserProfile(
                    userProfile,
                    lastFetchDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.month)),
                    lastMessagingDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.hour))
                )
                expectedAddresses.insert(userProfile.internalAddress)
            }

            do {
                // This profile is _not_ expected; lastFetchDate is recent.
                let userProfile = buildUserProfile()
                updateUserProfile(
                    userProfile,
                    lastFetchDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.minute)),
                    lastMessagingDate: .setTo(dateWithOffsetFromNow(-1 * TimeInterval.hour))
                )
            }
        }

        var missingAndStaleAddresses = Set<OWSUserProfile.Address>()
        self.read { transaction in
            StaleProfileFetcher.enumerateMissingAndStaleUserProfiles(now: now, tx: transaction) { userProfile in
                XCTAssertTrue(missingAndStaleAddresses.insert(userProfile.internalAddress).inserted)
            }
        }

        XCTAssertEqual(expectedAddresses, missingAndStaleAddresses)
    }
}
