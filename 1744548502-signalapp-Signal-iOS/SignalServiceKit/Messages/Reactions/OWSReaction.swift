//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import GRDB
public import LibSignalClient

@objc(OWSReaction) // Named explicitly to preserve NSKeyedUnarchiving compatability
public final class OWSReaction: NSObject, SDSCodableModel, Decodable, NSSecureCoding {
    public static let databaseTableName = "model_OWSReaction"
    public static var recordType: UInt { SDSRecordType.reaction.rawValue }

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case emoji
        case reactorE164
        case reactorUUID
        // See context on ``sortOrder`` below.
        case sortOrder = "receivedAtTimestamp"
        case sentAtTimestamp
        case uniqueMessageId
        case read
    }

    public var id: Int64?

    @objc
    public let uniqueId: String

    @objc
    public let uniqueMessageId: String

    public let emoji: String
    public let reactorAci: Aci?
    public let reactorPhoneNumber: String?
    public let sentAtTimestamp: UInt64
    /// Higher values mean more recent, i.e. should be rendered first in reaction lists.
    ///
    /// Historically, this would be the received timestamp (on the local device). However, the timestamp
    /// information is unavailable when restoring from a backup; that just has a sortOrder which makes
    /// no guarantees except that it can be used for sorting reactions for display.
    /// Locally, we can continue to write timestamps into here since they have the same sorting property
    /// as any other sortOrder value, and put those timestamps into our own backups as the "sortOrder".
    /// One edge case: restore a message with reactions and get a new reaction. Now we mix backup sortOrder
    /// values with local timestamp values. This should be fine; nobody will put any value into sortOrder
    /// larger than the current timestamp, anyway.
    public let sortOrder: UInt64
    public private(set) var read: Bool

    public var reactor: SignalServiceAddress {
        SignalServiceAddress.legacyAddress(serviceId: reactorAci, phoneNumber: reactorPhoneNumber)
    }

    /// Note that we initialize with a receivedAtTimestamp, but should make no assumptions
    /// that the sortOrder is always a timestamp at read time. Backups use sortOrders that
    /// may not be timestamps.
    public convenience init(
        uniqueMessageId: String,
        emoji: String,
        reactor: Aci,
        sentAtTimestamp: UInt64,
        receivedAtTimestamp: UInt64
    ) {
        self.init(
            uniqueMessageId: uniqueMessageId,
            emoji: emoji,
            reactorAci: reactor,
            reactorPhoneNumber: nil,
            sentAtTimestamp: sentAtTimestamp,
            sortOrder: receivedAtTimestamp
        )
    }

    private init(
        uniqueMessageId: String,
        emoji: String,
        reactorAci: Aci?,
        reactorPhoneNumber: String?,
        sentAtTimestamp: UInt64,
        sortOrder: UInt64
    ) {
        self.uniqueId = UUID().uuidString
        self.uniqueMessageId = uniqueMessageId
        self.emoji = emoji
        self.reactorAci = reactorAci
        self.reactorPhoneNumber = reactorPhoneNumber
        self.sentAtTimestamp = sentAtTimestamp
        self.sortOrder = sortOrder
        self.read = false
    }

    public static func fromRestoredBackup(
        uniqueMessageId: String,
        emoji: String,
        reactorAci: Aci,
        sentAtTimestamp: UInt64,
        sortOrder: UInt64
    ) -> Self {
        return Self.init(
            uniqueMessageId: uniqueMessageId,
            emoji: emoji,
            reactorAci: reactorAci,
            reactorPhoneNumber: nil,
            sentAtTimestamp: sentAtTimestamp,
            sortOrder: sortOrder
        )
    }

    public static func fromRestoredBackup(
        uniqueMessageId: String,
        emoji: String,
        reactorE164: E164,
        sentAtTimestamp: UInt64,
        sortOrder: UInt64
    ) -> OWSReaction {
        return .init(
            uniqueMessageId: uniqueMessageId,
            emoji: emoji,
            reactorAci: nil,
            reactorPhoneNumber: reactorE164.stringValue,
            sentAtTimestamp: sentAtTimestamp,
            sortOrder: sortOrder
        )
    }

    public func markAsRead(transaction: DBWriteTransaction) {
        anyUpdate(transaction: transaction) { reaction in
            reaction.read = true
        }
        SSKEnvironment.shared.notificationPresenterRef.cancelNotifications(reactionId: uniqueId)
    }

    @objc
    public static func anyEnumerateObjc(
        transaction: DBReadTransaction,
        batched: Bool,
        block: @escaping (OWSReaction, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        let batchingPreference: BatchingPreference = batched ? .batched() : .unbatched
        anyEnumerate(transaction: transaction, batchingPreference: batchingPreference, block: block)
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedRecordType = try container.decode(Int.self, forKey: .recordType)
        owsAssertDebug(decodedRecordType == Self.recordType, "Unexpectedly decoded record with wrong type.")

        id = try container.decodeIfPresent(RowId.self, forKey: .id)
        uniqueId = try container.decode(String.self, forKey: .uniqueId)

        uniqueMessageId = try container.decode(String.self, forKey: .uniqueMessageId)
        emoji = try container.decode(String.self, forKey: .emoji)

        // If we have an ACI, ignore the phone number.
        reactorAci = try container.decodeIfPresent(UUID.self, forKey: .reactorUUID).map { Aci(fromUUID: $0) }
        reactorPhoneNumber = (reactorAci != nil) ? nil : try container.decodeIfPresent(String.self, forKey: .reactorE164)

        sentAtTimestamp = try container.decode(UInt64.self, forKey: .sentAtTimestamp)
        sortOrder = try container.decode(UInt64.self, forKey: .sortOrder)
        read = try container.decode(Bool.self, forKey: .read)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try id.map { try container.encode($0, forKey: .id) }
        try container.encode(Self.recordType, forKey: .recordType)
        try container.encode(uniqueId, forKey: .uniqueId)

        try container.encode(uniqueMessageId, forKey: .uniqueMessageId)
        try container.encode(emoji, forKey: .emoji)

        // If we have an ACI, ignore the phone number.
        if let reactorAci {
            try container.encode(reactorAci.rawUUID, forKey: .reactorUUID)
        } else if let reactorPhoneNumber {
            try container.encode(reactorPhoneNumber, forKey: .reactorE164)
        }

        try container.encode(sentAtTimestamp, forKey: .sentAtTimestamp)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(read, forKey: .read)
    }

    // MARK: - NSSecureCoding

    public static var supportsSecureCoding: Bool { true }

    public func encode(with coder: NSCoder) {
        id.map { coder.encode(NSNumber(value: $0), forKey: CodingKeys.id.rawValue) }
        coder.encode(uniqueId, forKey: CodingKeys.uniqueId.rawValue)

        coder.encode(uniqueMessageId, forKey: CodingKeys.uniqueMessageId.rawValue)
        coder.encode(emoji, forKey: CodingKeys.emoji.rawValue)

        // If we have an ACI, ignore the phone number.
        if let reactorAci {
            coder.encode(reactorAci.rawUUID, forKey: CodingKeys.reactorUUID.rawValue)
        } else if let reactorPhoneNumber {
            coder.encode(reactorPhoneNumber, forKey: CodingKeys.reactorE164.rawValue)
        }

        coder.encode(NSNumber(value: sentAtTimestamp), forKey: CodingKeys.sentAtTimestamp.rawValue)
        coder.encode(NSNumber(value: sortOrder), forKey: CodingKeys.sortOrder.rawValue)
        coder.encode(NSNumber(value: read), forKey: CodingKeys.read.rawValue)
    }

    public required init?(coder: NSCoder) {
        self.id = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.id.rawValue)?.int64Value

        guard let uniqueId = coder.decodeObject(of: NSString.self, forKey: CodingKeys.uniqueId.rawValue) as String? else {
            owsFailDebug("Missing uniqueId")
            return nil
        }
        self.uniqueId = uniqueId

        guard let uniqueMessageId = coder.decodeObject(of: NSString.self, forKey: CodingKeys.uniqueMessageId.rawValue) as String? else {
            owsFailDebug("Missing uniqueMessageId")
            return nil
        }
        self.uniqueMessageId = uniqueMessageId

        guard let emoji = coder.decodeObject(of: NSString.self, forKey: CodingKeys.emoji.rawValue) as String? else {
            owsFailDebug("Missing emoji")
            return nil
        }
        self.emoji = emoji

        // If we have an ACI, ignore the phone number.
        let reactorAciUuid = coder.decodeObject(of: NSUUID.self, forKey: CodingKeys.reactorUUID.rawValue)
        reactorAci = reactorAciUuid.map { Aci(fromUUID: $0 as UUID) }
        reactorPhoneNumber = (reactorAci != nil) ? nil : {
            coder.decodeObject(of: NSString.self, forKey: CodingKeys.reactorE164.rawValue) as String?
        }()

        guard let sentAtTimestamp = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.sentAtTimestamp.rawValue)?.uint64Value else {
            owsFailDebug("Missing sentAtTimestamp")
            return nil
        }
        self.sentAtTimestamp = sentAtTimestamp

        guard let sortOrder = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.sortOrder.rawValue)?.uint64Value else {
            owsFailDebug("Missing sortOrder")
            return nil
        }
        self.sortOrder = sortOrder

        guard let read = coder.decodeObject(of: NSNumber.self, forKey: CodingKeys.read.rawValue)?.boolValue else {
            owsFailDebug("Missing read")
            return nil
        }
        self.read = read
    }
}
