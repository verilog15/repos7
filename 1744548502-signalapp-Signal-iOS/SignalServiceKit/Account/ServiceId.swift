//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient
public import GRDB

extension Aci {
    /// Parses an ACI from its string representation.
    ///
    /// - Note: Call this only if you **expect** an `Aci` (or nil). If the
    /// result could be a `Pni`, you shouldn't call this method.
    public static func parseFrom(aciString: String?) -> Aci? {
        guard let aciString else { return nil }
        guard let serviceId = try? ServiceId.parseFrom(serviceIdString: aciString) else { return nil }
        guard let aci = serviceId as? Aci else {
            return nil
        }
        return aci
    }
}

extension Pni {
    public static func parseFrom(pniString: String?) -> Pni? {
        guard let pniString else { return nil }
        guard let pniUuid = UUID(uuidString: pniString) else {
            return nil
        }
        return Pni(fromUUID: pniUuid)
    }

    public static func parseFrom(ambiguousString: String?) -> Pni? {
        guard let ambiguousString else { return nil }
        // Give LibSignal the first pass at parsing a "PNI:"-prefixed value.
        return (try? Pni.parseFrom(serviceIdString: ambiguousString)) ?? parseFrom(pniString: ambiguousString)
    }
}

extension ServiceId {
    public enum ConcreteType {
        case aci(Aci)
        case pni(Pni)
    }

    public var concreteType: ConcreteType {
        switch kind {
        case .aci: return .aci(self as! Aci)
        case .pni: return .pni(self as! Pni)
        }
    }
}

extension ProtocolAddress {
    public convenience init(_ serviceId: ServiceId, deviceId: DeviceId) {
        self.init(serviceId, deviceId: deviceId.uint32Value)
    }

    public var deviceIdObj: DeviceId {
        get throws {
            guard let result = DeviceId(validating: self.deviceId) else {
                throw OWSAssertionError("Invalid protocol address: must have valid deviceId")
            }
            return result
        }
    }
}

public struct AtLeastOneServiceId {
    /// Non-Optional because we must have at least an ACI or a PNI.
    public let aciOrElsePni: ServiceId

    public let aci: Aci?
    public let pni: Pni?

    public init?(aci: Aci?, pni: Pni?) {
        guard let aciOrElsePni = aci ?? pni else {
            return nil
        }
        self.aciOrElsePni = aciOrElsePni
        self.aci = aci
        self.pni = pni
    }
}

/// An "address" that's written to disk in a DB record.
///
/// This is the exact value that exists in the database, meaning that
///
///   `self == self.normalizedValue?.persistableValue`
///
/// may not always be true.
public struct PersistableDatabaseRecordAddress: Equatable {
    public let serviceId: ServiceId?
    public let phoneNumber: String?

    public init(serviceId: ServiceId?, phoneNumber: String?) {
        self.serviceId = serviceId
        self.phoneNumber = phoneNumber
    }
}

/// A "normalized address" that's written to various DB records.
///
/// New DB record types should generally store a foreign key to
/// `SignalRecipient`, but existing types may store a ServiceId/E164 pair.
///
/// For these older types, we often want to avoid storing phone numbers in
/// cases where we already know the ACI. This type does that.
public struct NormalizedDatabaseRecordAddress {
    public let serviceId: ServiceId?
    public let phoneNumber: String?

    public init(aci: Aci) {
        self.serviceId = aci
        self.phoneNumber = nil
    }

    private init(phoneNumber: String, pni: Pni?) {
        self.serviceId = pni
        self.phoneNumber = phoneNumber
    }

    private init(phoneNumber: String?, pni: Pni) {
        self.serviceId = pni
        self.phoneNumber = phoneNumber
    }

    public init?(aci: Aci?, phoneNumber: String?, pni: Pni?) {
        if let aci {
            self.init(aci: aci)
        } else if let pni {
            self.init(phoneNumber: phoneNumber, pni: pni)
        } else if let phoneNumber {
            self.init(phoneNumber: phoneNumber, pni: pni)
        } else {
            return nil
        }
    }

    public init?(serviceId: ServiceId?, phoneNumber: String?) {
        self.init(aci: serviceId as? Aci, phoneNumber: phoneNumber, pni: serviceId as? Pni)
    }

    public init?(serviceIdString: String?, phoneNumber: String?) {
        let serviceId = serviceIdString.flatMap { try? ServiceId.parseFrom(serviceIdString: $0) }
        self.init(serviceId: serviceId, phoneNumber: phoneNumber)
    }

    public init?(address: SignalServiceAddress?) {
        self.init(serviceId: address?.serviceId, phoneNumber: address?.phoneNumber)
    }

    public var persistableValue: PersistableDatabaseRecordAddress {
        return PersistableDatabaseRecordAddress(serviceId: serviceId, phoneNumber: phoneNumber)
    }
}

@objc
public class ServiceIdObjC: NSObject, NSCopying {
    public var wrappedValue: ServiceId { owsFail("Subclasses must implement.") }

    fileprivate override init() { super.init() }

    public static func wrapValue(_ wrappedValue: ServiceId) -> ServiceIdObjC {
        switch wrappedValue.kind {
        case .aci:
            return AciObjC(wrappedValue as! Aci)
        case .pni:
            return PniObjC(wrappedValue as! Pni)
        }
    }

    @objc
    public static func parseFrom(serviceIdString: String?) -> ServiceIdObjC? {
        guard let serviceIdString, let wrappedValue = try? ServiceId.parseFrom(serviceIdString: serviceIdString) else {
            return nil
        }
        return wrapValue(wrappedValue)
    }

    @objc
    public var serviceIdString: String { wrappedValue.serviceIdString }

    @objc
    public var serviceIdUppercaseString: String { wrappedValue.serviceIdUppercaseString }

    @objc
    public var rawUUID: UUID { wrappedValue.rawUUID }

    @objc
    public override var hash: Int { wrappedValue.hashValue }

    @objc
    public override func isEqual(_ object: Any?) -> Bool { wrappedValue == (object as? ServiceIdObjC)?.wrappedValue }

    @objc
    public func copy(with zone: NSZone? = nil) -> Any { self }

    @objc
    public override var description: String { wrappedValue.debugDescription }
}

@objc
public final class AciObjC: ServiceIdObjC {
    public let wrappedAciValue: Aci

    public override var wrappedValue: ServiceId { wrappedAciValue }

    public init(_ wrappedValue: Aci) {
        self.wrappedAciValue = wrappedValue
    }

    @objc
    public init(uuidValue: UUID) {
        self.wrappedAciValue = Aci(fromUUID: uuidValue)
    }

    @objc
    public init?(aciString: String?) {
        guard let aciValue = Aci.parseFrom(aciString: aciString) else {
            return nil
        }
        self.wrappedAciValue = aciValue
    }
}

@objc
public final class PniObjC: ServiceIdObjC {
    public let wrappedPniValue: Pni

    public override var wrappedValue: ServiceId { wrappedPniValue }

    public init(_ wrappedValue: Pni) {
        self.wrappedPniValue = wrappedValue
    }

    @objc
    public init(uuidValue: UUID) {
        self.wrappedPniValue = Pni(fromUUID: uuidValue)
    }
}

// MARK: - Codable

@propertyWrapper
public struct AciUuid: Codable, Equatable, Hashable, DatabaseValueConvertible {
    public let wrappedValue: Aci

    public init(wrappedValue: Aci) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = Aci(fromUUID: try decoder.singleValueContainer().decode(UUID.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue.rawUUID)
    }

    public var databaseValue: DatabaseValue { wrappedValue.rawUUID.databaseValue }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        UUID.fromDatabaseValue(dbValue).map { Self(wrappedValue: Aci(fromUUID: $0)) }
    }
}

extension Aci {
    public var codableUuid: AciUuid { .init(wrappedValue: self) }
}

@propertyWrapper
public struct PniUuid: Codable, Equatable, Hashable, DatabaseValueConvertible {
    public let wrappedValue: Pni

    public init(wrappedValue: Pni) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = Pni(fromUUID: try decoder.singleValueContainer().decode(UUID.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue.rawUUID)
    }

    public var databaseValue: DatabaseValue { wrappedValue.rawUUID.databaseValue }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        UUID.fromDatabaseValue(dbValue).map { Self(wrappedValue: Pni(fromUUID: $0)) }
    }
}

extension Pni {
    public var codableUuid: PniUuid { .init(wrappedValue: self) }
}

@propertyWrapper
public struct ServiceIdString: Codable, Hashable {
    public let wrappedValue: ServiceId

    public init(wrappedValue: ServiceId) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = try ServiceId.parseFrom(
            serviceIdString: try decoder.singleValueContainer().decode(String.self)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue.serviceIdString)
    }
}

@propertyWrapper
public struct ServiceIdUppercaseString: Codable, Hashable {
    public let wrappedValue: ServiceId

    public init(wrappedValue: ServiceId) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = try ServiceId.parseFrom(
            serviceIdString: try decoder.singleValueContainer().decode(String.self)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue.serviceIdUppercaseString)
    }
}

extension ServiceId {
    public var codableUppercaseString: ServiceIdUppercaseString { .init(wrappedValue: self) }
}

// MARK: - Unit Tests

#if TESTABLE_BUILD

extension Aci {
    public static func randomForTesting() -> Aci {
        Aci(fromUUID: UUID())
    }

    public static func constantForTesting(_ uuidString: String) -> Aci {
        try! ServiceId.parseFrom(serviceIdString: uuidString) as! Aci
     }
 }

extension Pni {
    public static func randomForTesting() -> Pni {
        Pni(fromUUID: UUID())
    }

    public static func constantForTesting(_ serviceIdString: String) -> Pni {
        try! ServiceId.parseFrom(serviceIdString: serviceIdString) as! Pni
    }
}

#endif
