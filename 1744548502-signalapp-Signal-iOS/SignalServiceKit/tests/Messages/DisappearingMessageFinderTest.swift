//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import LibSignalClient
import XCTest

@testable import SignalServiceKit

final class DisappearingMessageFinderTest: SSKBaseTest {
    private var finder: DisappearingMessagesFinder!
    private let now: UInt64 = 1700000000000

    override func setUp() {
        super.setUp()
        finder = DisappearingMessagesFinder()
    }

    private func localAddress() -> SignalServiceAddress { LocalIdentifiers.forUnitTests.aciAddress }

    private lazy var otherAddress = SignalServiceAddress(Aci.randomForTesting())

    private func thread(with transaction: DBWriteTransaction) -> TSThread {
        TSContactThread.getOrCreateThread(
            withContactAddress: otherAddress,
            transaction: transaction
        )
    }

    @discardableResult
    private func incomingMessage(
        withBody body: String,
        expiresInSeconds: UInt32,
        expireStartedAt: UInt64,
        markAsRead: Bool = false
    ) -> TSIncomingMessage {
        write { transaction -> TSIncomingMessage in
            // It only makes sense to "mark as read" if expiration hasn't started,
            // since we don't start expiration for unread incoming messages.
            owsPrecondition(!markAsRead || expireStartedAt == 0)

            let thread = self.thread(with: transaction)

            let incomingMessageBuilder: TSIncomingMessageBuilder = .withDefaultValues(
                thread: thread,
                timestamp: 1,
                authorAci: otherAddress.aci,
                messageBody: body,
                expiresInSeconds: expiresInSeconds
            )
            let message = incomingMessageBuilder.build()
            message.anyInsert(transaction: transaction)

            if expireStartedAt > 0 {
                message.markAsRead(
                    atTimestamp: expireStartedAt,
                    thread: thread,
                    circumstance: .onLinkedDevice,
                    shouldClearNotifications: true,
                    transaction: transaction
                )
            } else if markAsRead {
                message.markAsRead(
                    atTimestamp: now - 1000,
                    thread: thread,
                    circumstance: .onLinkedDevice,
                    shouldClearNotifications: true,
                    transaction: transaction
                )
            }

            return message
        }
    }

    @discardableResult
    private func outgoingMessage(
        withBody body: String,
        expiresInSeconds: UInt32,
        expireStartedAt: UInt64
    ) -> TSOutgoingMessage {
        write { transaction in
            let thread = self.thread(with: transaction)

            let messageBuilder: TSOutgoingMessageBuilder = .withDefaultValues(
                thread: thread,
                messageBody: body,
                expiresInSeconds: expiresInSeconds,
                expireStartedAt: expireStartedAt
            )

            let message = messageBuilder.build(transaction: transaction)
            message.anyInsert(transaction: transaction)
            return message
        }
    }

    func testExpiredMessages() throws {
        let expiredMessage1 = incomingMessage(
            withBody: "expiredMessage1",
            expiresInSeconds: 2,
            expireStartedAt: now - 2000
        )
        let expiredMessage2 = incomingMessage(
            withBody: "expiredMessage2",
            expiresInSeconds: 1,
            expireStartedAt: now - 20000
        )

        incomingMessage(
            withBody: "notYetExpiredMessage",
            expiresInSeconds: 2,
            expireStartedAt: now - 1999
        )
        incomingMessage(
            withBody: "unreadExpiringMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0
        )
        incomingMessage(
            withBody: "unexpiringMessage",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )
        incomingMessage(
            withBody: "unexpiringMessage2",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )

        let rowIds = try SSKEnvironment.shared.databaseStorageRef.read { tx in
            try InteractionFinder.fetchSomeExpiredMessageRowIds(now: now, limit: 3, tx: tx)
        }
        XCTAssertEqual(Set(rowIds), [expiredMessage1.sqliteRowId!, expiredMessage2.sqliteRowId!])
    }

    func testUnstartedExpiredMessagesForThread() {
        let expiredIncomingMessage = incomingMessage(
            withBody: "incoming expiredMessage",
            expiresInSeconds: 2,
            expireStartedAt: now - 2000
        )
        let notYetExpiredIncomingMessage = incomingMessage(
            withBody: "incoming notYetExpiredMessage",
            expiresInSeconds: 20,
            expireStartedAt: now - 10000
        )
        let unreadExpiringIncomingMessage = incomingMessage(
            withBody: "incoming unreadExpiringMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0
        )
        let readExpiringIncomingMessage = incomingMessage(
            withBody: "incoming readExpiringMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0,
            markAsRead: true
        )
        let unExpiringIncomingMessage = incomingMessage(
            withBody: "incoming unexpiringMessage",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )
        let unExpiringIncomingMessage2 = incomingMessage(
            withBody: "incoming unexpiringMessage2",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )

        let expiredOutgoingMessage = outgoingMessage(
            withBody: "outgoing expiredMessage",
            expiresInSeconds: 2,
            expireStartedAt: now - 2000
        )
        let notYetExpiredOutgoingMessage = outgoingMessage(
            withBody: "outgoing notYetExpiredMessage",
            expiresInSeconds: 20,
            expireStartedAt: now - 10000
        )
        let expiringUnsentOutgoingMessage = outgoingMessage(
            withBody: "expiringUnsentOutgoingMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0
        )
        let expiringSentOutgoingMessage = outgoingMessage(
            withBody: "expiringSentOutgoingMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0
        )
        let expiringDeliveredOutgoingMessage = outgoingMessage(
            withBody: "expiringDeliveredOutgoingMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0
        )
        let expiringDeliveredAndReadOutgoingMessage = outgoingMessage(
            withBody: "expiringDeliveredAndReadOutgoingMessage",
            expiresInSeconds: 10,
            expireStartedAt: 0
        )
        let unExpiringOutgoingMessage = outgoingMessage(
            withBody: "outgoing unexpiringMessage",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )
        let unExpiringOutgoingMessage2 = outgoingMessage(
            withBody: "outgoing unexpiringMessage2",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )

        write { transaction in
            // Mark outgoing message as "sent", "delivered" or "delivered and read" using production methods.
            for message in [
                expiringSentOutgoingMessage,
                expiringDeliveredOutgoingMessage,
                expiringDeliveredAndReadOutgoingMessage
            ] {
                // To model production behavior, mark messages as "sent" before
                // optionally marking as "delivered" or "read".
                message.updateWithSentRecipients(
                    [otherAddress.serviceId!],
                    wasSentByUD: false,
                    transaction: transaction
                )
            }

            expiringDeliveredOutgoingMessage.update(
                withDeliveredRecipient: otherAddress,
                deviceId: DeviceId(validating: 1)!,
                deliveryTimestamp: now,
                context: PassthroughDeliveryReceiptContext(),
                tx: transaction
            )
            expiringDeliveredAndReadOutgoingMessage.update(
                withReadRecipient: otherAddress,
                deviceId: DeviceId(validating: 1)!,
                readTimestamp: now,
                tx: transaction
            )
        }

        let shouldBeExpiringMessages: [TSMessage] = [
            expiredIncomingMessage,
            notYetExpiredIncomingMessage,
            readExpiringIncomingMessage,
            expiringSentOutgoingMessage,
            expiringDeliveredOutgoingMessage,
            expiringDeliveredAndReadOutgoingMessage,
            expiredOutgoingMessage,
            notYetExpiredOutgoingMessage
        ]
        let shouldNotBeExpiringMessages: [TSMessage] = [
            unreadExpiringIncomingMessage,
            unExpiringIncomingMessage,
            unExpiringIncomingMessage2,
            expiringUnsentOutgoingMessage,
            unExpiringOutgoingMessage,
            unExpiringOutgoingMessage2
        ]

        write { tx in
            for oldMessage in shouldBeExpiringMessages {
                let messageId = oldMessage.uniqueId
                let shouldBeExpiring = true
                let message = TSMessage.anyFetch(uniqueId: messageId, transaction: tx) as? TSMessage
                let logTag = "\(messageId) \(oldMessage.body ?? "nil")"
                guard let message else {
                    XCTFail("Missing message: \(logTag)")
                    continue
                }
                XCTAssertEqual(shouldBeExpiring, message.shouldStartExpireTimer(), logTag)
                XCTAssertEqual(shouldBeExpiring, message.storedShouldStartExpireTimer, logTag)
                XCTAssertTrue(message.expiresAt > 0, logTag)
            }

            for oldMessage in shouldNotBeExpiringMessages {
                let messageId = oldMessage.uniqueId
                let shouldBeExpiring = false
                let message = TSMessage.anyFetch(uniqueId: messageId, transaction: tx) as? TSMessage
                let logTag = "\(messageId) \(oldMessage.body ?? "nil")"
                guard let message else {
                    XCTFail("Missing message: \(logTag)")
                    continue
                }
                XCTAssertEqual(shouldBeExpiring, message.shouldStartExpireTimer(), logTag)
                XCTAssertEqual(shouldBeExpiring, message.storedShouldStartExpireTimer, logTag)
                XCTAssertEqual(message.expiresAt, 0, logTag)
            }

            let failedToStart = InteractionFinder.fetchAllMessageUniqueIdsWhichFailedToStartExpiring(transaction: tx)
            XCTAssertEqual(failedToStart, [])
        }
    }

    func nextExpirationTimestamp() -> UInt64? {
        var result: UInt64?
        read { transaction in
            result = finder.nextExpirationTimestamp(transaction: transaction)
        }
        return result
    }

    func testNextExpirationTimestampNilWhenNoExpiringMessages() {
        // Sanity check.
        XCTAssertNil(nextExpirationTimestamp())

        incomingMessage(
            withBody: "unexpiringMessage",
            expiresInSeconds: 0,
            expireStartedAt: 0
        )
        XCTAssertNil(nextExpirationTimestamp())
    }

    func testNextExpirationTimestampNotNilWithUpcomingExpiringMessages() throws {
        incomingMessage(
            withBody: "soonToExpireMessage",
            expiresInSeconds: 10,
            expireStartedAt: now - 9000
        )

        XCTAssertEqual(now + 1000, try XCTUnwrap(nextExpirationTimestamp()))

        // expired message should take precedence
        incomingMessage(
            withBody: "expiredMessage",
            expiresInSeconds: 10,
            expireStartedAt: now - 11000
        )
        XCTAssertEqual(now - 1000, try XCTUnwrap(nextExpirationTimestamp()))
    }
}
