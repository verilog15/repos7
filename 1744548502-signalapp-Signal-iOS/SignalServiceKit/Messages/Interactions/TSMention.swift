//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import GRDB
public import LibSignalClient

@objc
public final class TSMention: NSObject, SDSCodableModel, Decodable {
    public static let databaseTableName = "model_TSMention"
    public static var recordType: UInt { SDSRecordType.mention.rawValue }

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case uniqueMessageId
        case uniqueThreadId
        case aciString = "uuidString"
        case creationTimestamp
    }

    public var id: Int64?

    @objc
    public let uniqueId: String
    @objc
    public let uniqueMessageId: String

    public let uniqueThreadId: String
    public let aciString: String
    public let creationDate: Date
    public var address: SignalServiceAddress { SignalServiceAddress(aciString: aciString) }

    public init(uniqueMessageId: String, uniqueThreadId: String, aci: Aci) {
        self.uniqueId = UUID().uuidString
        self.uniqueMessageId = uniqueMessageId
        self.uniqueThreadId = uniqueThreadId
        self.aciString = aci.serviceIdUppercaseString
        self.creationDate = Date()
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedRecordType = try container.decode(Int.self, forKey: .recordType)
        owsAssertDebug(decodedRecordType == Self.recordType, "Unexpectedly decoded record with wrong type.")

        id = try container.decodeIfPresent(RowId.self, forKey: .id)
        uniqueId = try container.decode(String.self, forKey: .uniqueId)

        uniqueMessageId = try container.decode(String.self, forKey: .uniqueMessageId)
        uniqueThreadId = try container.decode(String.self, forKey: .uniqueThreadId)
        aciString = try container.decode(String.self, forKey: .aciString)
        creationDate = try container.decode(Date.self, forKey: .creationTimestamp)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try id.map { try container.encode($0, forKey: .id) }
        try container.encode(Self.recordType, forKey: .recordType)
        try container.encode(uniqueId, forKey: .uniqueId)

        try container.encode(uniqueMessageId, forKey: .uniqueMessageId)
        try container.encode(uniqueThreadId, forKey: .uniqueThreadId)
        try container.encode(aciString, forKey: .aciString)
        try container.encode(creationDate, forKey: .creationTimestamp)
    }

    @objc
    public static func anyEnumerateObjc(
        transaction: DBReadTransaction,
        batched: Bool,
        block: @escaping (TSMention, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        let batchingPreference: BatchingPreference = batched ? .batched() : .unbatched
        anyEnumerate(transaction: transaction, batchingPreference: batchingPreference, block: block)
    }
}
