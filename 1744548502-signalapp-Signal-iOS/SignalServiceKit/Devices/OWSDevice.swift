//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import GRDB

public final class OWSDevice: SDSCodableModel, Decodable {
    public static let primaryDeviceId: UInt32 = 1

    public static let databaseTableName: String = "model_OWSDevice"
    public static var recordType: UInt { SDSRecordType.device.rawValue }

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId

        case deviceId
        case encryptedName = "name"
        case createdAt
        case lastSeenAt
    }

    public var id: RowId?
    public let uniqueId: String

    public let deviceId: Int
    public var encryptedName: String?
    public let createdAt: Date
    public let lastSeenAt: Date

    init(
        deviceId: Int,
        encryptedName: String?,
        createdAt: Date,
        lastSeenAt: Date
    ) {
        self.uniqueId = UUID().uuidString

        self.deviceId = deviceId
        self.encryptedName = encryptedName
        self.createdAt = createdAt
        self.lastSeenAt = lastSeenAt
    }

#if DEBUG
    public static func previewItem(id: Int) -> OWSDevice {
        OWSDevice(
            deviceId: id,
            encryptedName: nil,
            createdAt: Date().addingTimeInterval(-86_400 * TimeInterval(Int.random(in: 10...20))),
            lastSeenAt: Date().addingTimeInterval(-86_400 * TimeInterval(Int.random(in: 0...10)))
        )
    }
#endif

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedRecordType = try container.decode(UInt.self, forKey: .recordType)
        owsAssertDebug(decodedRecordType == Self.recordType, "Unexpectedly decoded record with wrong type!")

        id = try container.decodeIfPresent(RowId.self, forKey: .id)
        uniqueId = try container.decode(String.self, forKey: .uniqueId)

        deviceId = try container.decode(Int.self, forKey: .deviceId)
        encryptedName = try container.decodeIfPresent(String.self, forKey: .encryptedName)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastSeenAt = try container.decode(Date.self, forKey: .lastSeenAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(Self.recordType, forKey: .recordType)

        try id.map { try container.encode($0, forKey: .id) }
        try container.encode(uniqueId, forKey: .uniqueId)

        try container.encode(deviceId, forKey: .deviceId)
        try container.encodeIfPresent(encryptedName, forKey: .encryptedName)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastSeenAt, forKey: .lastSeenAt)
    }
}

public extension OWSDevice {
    func displayName(
        identityManager: OWSIdentityManager,
        tx: DBReadTransaction
    ) -> String {
        if let encryptedName = self.encryptedName {
            if let identityKeyPair = identityManager.identityKeyPair(for: .aci, tx: tx) {
                do {
                    return try DeviceNames.decryptDeviceName(
                        base64String: encryptedName,
                        identityKeyPair: identityKeyPair.keyPair
                    )
                } catch let error {
                    Logger.error("Failed to decrypt device name: \(error). Is this a legacy device name?")
                }
            }

            return encryptedName
        }

        if deviceId == Self.primaryDeviceId {
            return OWSLocalizedString(
                "DEVICE_NAME_THIS_DEVICE",
                comment: "A label for this device in the device list."
            )
        }

        return OWSLocalizedString(
            "DEVICE_NAME_UNNAMED_DEVICE",
            comment: "A label for an unnamed device in the device list."
        )
    }

    var isPrimaryDevice: Bool {
        deviceId == Self.primaryDeviceId
    }

    var isLinkedDevice: Bool {
        !isPrimaryDevice
    }
}

// MARK: - Replace all

public extension OWSDevice {

    /// Update our persisted devices to match the given devices.
    ///
    /// - Returns
    /// `true` if any devices were added or removed, and `false` otherwise.
    static func replaceAll(
        with newDevices: [OWSDevice],
        transaction: DBWriteTransaction
    ) -> Bool {
        let existingDevices = anyFetchAll(transaction: transaction)

        for existingDevice in existingDevices {
            existingDevice.anyRemove(transaction: transaction)
        }

        for newDevice in newDevices {
            newDevice.anyInsert(transaction: transaction)
        }

        let existingDeviceIds = Set(existingDevices.map { $0.deviceId })
        let newDeviceIds = Set(newDevices.map { $0.deviceId })

        return !newDeviceIds.symmetricDifference(existingDeviceIds).isEmpty
    }
}
