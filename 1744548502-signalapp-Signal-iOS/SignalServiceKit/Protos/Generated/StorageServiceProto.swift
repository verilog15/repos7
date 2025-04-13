//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import SwiftProtobuf

// WARNING: This code is generated. Only edit within the markers.

public enum StorageServiceProtoError: Error {
    case invalidProtobuf(description: String)
}

// MARK: - StorageServiceProtoOptionalBool

public enum StorageServiceProtoOptionalBool: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unset // 0
    case `true` // 1
    case `false` // 2
    case UNRECOGNIZED(Int)

    public init() {
        self = .unset
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .unset
            case 1: self = .true
            case 2: self = .false
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .unset: return 0
            case .true: return 1
            case .false: return 2
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoOptionalBoolWrap(_ value: StorageServiceProtos_OptionalBool) -> StorageServiceProtoOptionalBool {
    switch value {
    case .unset: return .unset
    case .true: return .true
    case .false: return .false
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoOptionalBoolUnwrap(_ value: StorageServiceProtoOptionalBool) -> StorageServiceProtos_OptionalBool {
    switch value {
    case .unset: return .unset
    case .true: return .true
    case .false: return .false
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoAvatarColor

public enum StorageServiceProtoAvatarColor: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case a100 // 0
    case a110 // 1
    case a120 // 2
    case a130 // 3
    case a140 // 4
    case a150 // 5
    case a160 // 6
    case a170 // 7
    case a180 // 8
    case a190 // 9
    case a200 // 10
    case a210 // 11
    case UNRECOGNIZED(Int)

    public init() {
        self = .a100
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .a100
            case 1: self = .a110
            case 2: self = .a120
            case 3: self = .a130
            case 4: self = .a140
            case 5: self = .a150
            case 6: self = .a160
            case 7: self = .a170
            case 8: self = .a180
            case 9: self = .a190
            case 10: self = .a200
            case 11: self = .a210
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .a100: return 0
            case .a110: return 1
            case .a120: return 2
            case .a130: return 3
            case .a140: return 4
            case .a150: return 5
            case .a160: return 6
            case .a170: return 7
            case .a180: return 8
            case .a190: return 9
            case .a200: return 10
            case .a210: return 11
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoAvatarColorWrap(_ value: StorageServiceProtos_AvatarColor) -> StorageServiceProtoAvatarColor {
    switch value {
    case .a100: return .a100
    case .a110: return .a110
    case .a120: return .a120
    case .a130: return .a130
    case .a140: return .a140
    case .a150: return .a150
    case .a160: return .a160
    case .a170: return .a170
    case .a180: return .a180
    case .a190: return .a190
    case .a200: return .a200
    case .a210: return .a210
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoAvatarColorUnwrap(_ value: StorageServiceProtoAvatarColor) -> StorageServiceProtos_AvatarColor {
    switch value {
    case .a100: return .a100
    case .a110: return .a110
    case .a120: return .a120
    case .a130: return .a130
    case .a140: return .a140
    case .a150: return .a150
    case .a160: return .a160
    case .a170: return .a170
    case .a180: return .a180
    case .a190: return .a190
    case .a200: return .a200
    case .a210: return .a210
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoStorageItem

public struct StorageServiceProtoStorageItem: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_StorageItem

    public let key: Data

    public let value: Data

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_StorageItem,
                 key: Data,
                 value: Data) {
        self.proto = proto
        self.key = key
        self.value = value
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_StorageItem(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_StorageItem) {
        let key = proto.key

        let value = proto.value

        self.init(proto: proto,
                  key: key,
                  value: value)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoStorageItem {
    public static func builder(key: Data, value: Data) -> StorageServiceProtoStorageItemBuilder {
        return StorageServiceProtoStorageItemBuilder(key: key, value: value)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoStorageItemBuilder {
        var builder = StorageServiceProtoStorageItemBuilder(key: key, value: value)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoStorageItemBuilder {

    private var proto = StorageServiceProtos_StorageItem()

    fileprivate init() {}

    fileprivate init(key: Data, value: Data) {

        setKey(key)
        setValue(value)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setKey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.key = valueParam
    }

    public mutating func setKey(_ valueParam: Data) {
        proto.key = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setValue(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.value = valueParam
    }

    public mutating func setValue(_ valueParam: Data) {
        proto.value = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoStorageItem {
        return StorageServiceProtoStorageItem(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoStorageItem(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoStorageItem {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoStorageItemBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoStorageItem? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoStorageItems

public struct StorageServiceProtoStorageItems: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_StorageItems

    public let items: [StorageServiceProtoStorageItem]

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_StorageItems,
                 items: [StorageServiceProtoStorageItem]) {
        self.proto = proto
        self.items = items
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_StorageItems(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_StorageItems) {
        var items: [StorageServiceProtoStorageItem] = []
        items = proto.items.map { StorageServiceProtoStorageItem($0) }

        self.init(proto: proto,
                  items: items)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoStorageItems {
    public static func builder() -> StorageServiceProtoStorageItemsBuilder {
        return StorageServiceProtoStorageItemsBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoStorageItemsBuilder {
        var builder = StorageServiceProtoStorageItemsBuilder()
        builder.setItems(items)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoStorageItemsBuilder {

    private var proto = StorageServiceProtos_StorageItems()

    fileprivate init() {}

    public mutating func addItems(_ valueParam: StorageServiceProtoStorageItem) {
        proto.items.append(valueParam.proto)
    }

    public mutating func setItems(_ wrappedItems: [StorageServiceProtoStorageItem]) {
        proto.items = wrappedItems.map { $0.proto }
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoStorageItems {
        return StorageServiceProtoStorageItems(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoStorageItems(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoStorageItems {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoStorageItemsBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoStorageItems? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoStorageManifest

public struct StorageServiceProtoStorageManifest: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_StorageManifest

    public let version: UInt64

    public let value: Data

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_StorageManifest,
                 version: UInt64,
                 value: Data) {
        self.proto = proto
        self.version = version
        self.value = value
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_StorageManifest(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_StorageManifest) {
        let version = proto.version

        let value = proto.value

        self.init(proto: proto,
                  version: version,
                  value: value)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoStorageManifest {
    public static func builder(version: UInt64, value: Data) -> StorageServiceProtoStorageManifestBuilder {
        return StorageServiceProtoStorageManifestBuilder(version: version, value: value)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoStorageManifestBuilder {
        var builder = StorageServiceProtoStorageManifestBuilder(version: version, value: value)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoStorageManifestBuilder {

    private var proto = StorageServiceProtos_StorageManifest()

    fileprivate init() {}

    fileprivate init(version: UInt64, value: Data) {

        setVersion(version)
        setValue(value)
    }

    public mutating func setVersion(_ valueParam: UInt64) {
        proto.version = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setValue(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.value = valueParam
    }

    public mutating func setValue(_ valueParam: Data) {
        proto.value = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoStorageManifest {
        return StorageServiceProtoStorageManifest(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoStorageManifest(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoStorageManifest {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoStorageManifestBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoStorageManifest? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoReadOperation

public struct StorageServiceProtoReadOperation: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_ReadOperation

    public var readKey: [Data] {
        return proto.readKey
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_ReadOperation) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_ReadOperation(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_ReadOperation) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoReadOperation {
    public static func builder() -> StorageServiceProtoReadOperationBuilder {
        return StorageServiceProtoReadOperationBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoReadOperationBuilder {
        var builder = StorageServiceProtoReadOperationBuilder()
        builder.setReadKey(readKey)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoReadOperationBuilder {

    private var proto = StorageServiceProtos_ReadOperation()

    fileprivate init() {}

    public mutating func addReadKey(_ valueParam: Data) {
        proto.readKey.append(valueParam)
    }

    public mutating func setReadKey(_ wrappedItems: [Data]) {
        proto.readKey = wrappedItems
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoReadOperation {
        return StorageServiceProtoReadOperation(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoReadOperation(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoReadOperation {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoReadOperationBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoReadOperation? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoWriteOperation

public struct StorageServiceProtoWriteOperation: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_WriteOperation

    public let manifest: StorageServiceProtoStorageManifest?

    public let insertItem: [StorageServiceProtoStorageItem]

    public var deleteKey: [Data] {
        return proto.deleteKey
    }

    public var deleteAll: Bool {
        return proto.deleteAll
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_WriteOperation,
                 manifest: StorageServiceProtoStorageManifest?,
                 insertItem: [StorageServiceProtoStorageItem]) {
        self.proto = proto
        self.manifest = manifest
        self.insertItem = insertItem
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_WriteOperation(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_WriteOperation) {
        var manifest: StorageServiceProtoStorageManifest?
        if proto.hasManifest {
            manifest = StorageServiceProtoStorageManifest(proto.manifest)
        }

        var insertItem: [StorageServiceProtoStorageItem] = []
        insertItem = proto.insertItem.map { StorageServiceProtoStorageItem($0) }

        self.init(proto: proto,
                  manifest: manifest,
                  insertItem: insertItem)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoWriteOperation {
    public static func builder() -> StorageServiceProtoWriteOperationBuilder {
        return StorageServiceProtoWriteOperationBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoWriteOperationBuilder {
        var builder = StorageServiceProtoWriteOperationBuilder()
        if let _value = manifest {
            builder.setManifest(_value)
        }
        builder.setInsertItem(insertItem)
        builder.setDeleteKey(deleteKey)
        builder.setDeleteAll(deleteAll)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoWriteOperationBuilder {

    private var proto = StorageServiceProtos_WriteOperation()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setManifest(_ valueParam: StorageServiceProtoStorageManifest?) {
        guard let valueParam = valueParam else { return }
        proto.manifest = valueParam.proto
    }

    public mutating func setManifest(_ valueParam: StorageServiceProtoStorageManifest) {
        proto.manifest = valueParam.proto
    }

    public mutating func addInsertItem(_ valueParam: StorageServiceProtoStorageItem) {
        proto.insertItem.append(valueParam.proto)
    }

    public mutating func setInsertItem(_ wrappedItems: [StorageServiceProtoStorageItem]) {
        proto.insertItem = wrappedItems.map { $0.proto }
    }

    public mutating func addDeleteKey(_ valueParam: Data) {
        proto.deleteKey.append(valueParam)
    }

    public mutating func setDeleteKey(_ wrappedItems: [Data]) {
        proto.deleteKey = wrappedItems
    }

    public mutating func setDeleteAll(_ valueParam: Bool) {
        proto.deleteAll = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoWriteOperation {
        return StorageServiceProtoWriteOperation(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoWriteOperation(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoWriteOperation {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoWriteOperationBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoWriteOperation? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoManifestRecordKeyType

public enum StorageServiceProtoManifestRecordKeyType: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unknown // 0
    case contact // 1
    case groupv1 // 2
    case groupv2 // 3
    case account // 4
    case storyDistributionList // 5
    case callLink // 7
    case UNRECOGNIZED(Int)

    public init() {
        self = .unknown
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .unknown
            case 1: self = .contact
            case 2: self = .groupv1
            case 3: self = .groupv2
            case 4: self = .account
            case 5: self = .storyDistributionList
            case 7: self = .callLink
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .unknown: return 0
            case .contact: return 1
            case .groupv1: return 2
            case .groupv2: return 3
            case .account: return 4
            case .storyDistributionList: return 5
            case .callLink: return 7
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoManifestRecordKeyTypeWrap(_ value: StorageServiceProtos_ManifestRecord.Key.TypeEnum) -> StorageServiceProtoManifestRecordKeyType {
    switch value {
    case .unknown: return .unknown
    case .contact: return .contact
    case .groupv1: return .groupv1
    case .groupv2: return .groupv2
    case .account: return .account
    case .storyDistributionList: return .storyDistributionList
    case .callLink: return .callLink
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoManifestRecordKeyTypeUnwrap(_ value: StorageServiceProtoManifestRecordKeyType) -> StorageServiceProtos_ManifestRecord.Key.TypeEnum {
    switch value {
    case .unknown: return .unknown
    case .contact: return .contact
    case .groupv1: return .groupv1
    case .groupv2: return .groupv2
    case .account: return .account
    case .storyDistributionList: return .storyDistributionList
    case .callLink: return .callLink
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoManifestRecordKey

public struct StorageServiceProtoManifestRecordKey: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_ManifestRecord.Key

    public let data: Data

    public let type: StorageServiceProtoManifestRecordKeyType

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_ManifestRecord.Key,
                 data: Data,
                 type: StorageServiceProtoManifestRecordKeyType) {
        self.proto = proto
        self.data = data
        self.type = type
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_ManifestRecord.Key(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_ManifestRecord.Key) {
        let data = proto.data

        let type = StorageServiceProtoManifestRecordKeyTypeWrap(proto.type)

        self.init(proto: proto,
                  data: data,
                  type: type)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoManifestRecordKey {
    public static func builder(data: Data, type: StorageServiceProtoManifestRecordKeyType) -> StorageServiceProtoManifestRecordKeyBuilder {
        return StorageServiceProtoManifestRecordKeyBuilder(data: data, type: type)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoManifestRecordKeyBuilder {
        var builder = StorageServiceProtoManifestRecordKeyBuilder(data: data, type: type)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoManifestRecordKeyBuilder {

    private var proto = StorageServiceProtos_ManifestRecord.Key()

    fileprivate init() {}

    fileprivate init(data: Data, type: StorageServiceProtoManifestRecordKeyType) {

        setData(data)
        setType(type)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setData(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.data = valueParam
    }

    public mutating func setData(_ valueParam: Data) {
        proto.data = valueParam
    }

    public mutating func setType(_ valueParam: StorageServiceProtoManifestRecordKeyType) {
        proto.type = StorageServiceProtoManifestRecordKeyTypeUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoManifestRecordKey {
        return StorageServiceProtoManifestRecordKey(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoManifestRecordKey(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoManifestRecordKey {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoManifestRecordKeyBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoManifestRecordKey? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoManifestRecord

public struct StorageServiceProtoManifestRecord: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_ManifestRecord

    public let version: UInt64

    public let keys: [StorageServiceProtoManifestRecordKey]

    public var sourceDevice: UInt32 {
        return proto.sourceDevice
    }
    public var recordIkm: Data? {
        guard hasRecordIkm else {
            return nil
        }
        return proto.recordIkm
    }
    public var hasRecordIkm: Bool {
        return !proto.recordIkm.isEmpty
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_ManifestRecord,
                 version: UInt64,
                 keys: [StorageServiceProtoManifestRecordKey]) {
        self.proto = proto
        self.version = version
        self.keys = keys
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_ManifestRecord(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_ManifestRecord) {
        let version = proto.version

        var keys: [StorageServiceProtoManifestRecordKey] = []
        keys = proto.keys.map { StorageServiceProtoManifestRecordKey($0) }

        self.init(proto: proto,
                  version: version,
                  keys: keys)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoManifestRecord {
    public static func builder(version: UInt64) -> StorageServiceProtoManifestRecordBuilder {
        return StorageServiceProtoManifestRecordBuilder(version: version)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoManifestRecordBuilder {
        var builder = StorageServiceProtoManifestRecordBuilder(version: version)
        builder.setSourceDevice(sourceDevice)
        builder.setKeys(keys)
        if let _value = recordIkm {
            builder.setRecordIkm(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoManifestRecordBuilder {

    private var proto = StorageServiceProtos_ManifestRecord()

    fileprivate init() {}

    fileprivate init(version: UInt64) {

        setVersion(version)
    }

    public mutating func setVersion(_ valueParam: UInt64) {
        proto.version = valueParam
    }

    public mutating func setSourceDevice(_ valueParam: UInt32) {
        proto.sourceDevice = valueParam
    }

    public mutating func addKeys(_ valueParam: StorageServiceProtoManifestRecordKey) {
        proto.keys.append(valueParam.proto)
    }

    public mutating func setKeys(_ wrappedItems: [StorageServiceProtoManifestRecordKey]) {
        proto.keys = wrappedItems.map { $0.proto }
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setRecordIkm(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.recordIkm = valueParam
    }

    public mutating func setRecordIkm(_ valueParam: Data) {
        proto.recordIkm = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoManifestRecord {
        return StorageServiceProtoManifestRecord(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoManifestRecord(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoManifestRecord {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoManifestRecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoManifestRecord? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoStorageRecordOneOfRecord

public enum StorageServiceProtoStorageRecordOneOfRecord {
    case contact(StorageServiceProtoContactRecord)
    case groupV1(StorageServiceProtoGroupV1Record)
    case groupV2(StorageServiceProtoGroupV2Record)
    case account(StorageServiceProtoAccountRecord)
    case storyDistributionList(StorageServiceProtoStoryDistributionListRecord)
    case callLink(StorageServiceProtoCallLinkRecord)
}

private func StorageServiceProtoStorageRecordOneOfRecordWrap(_ value: StorageServiceProtos_StorageRecord.OneOf_Record) -> StorageServiceProtoStorageRecordOneOfRecord {
    switch value {
    case .contact(let value): return .contact(StorageServiceProtoContactRecord(value))
    case .groupV1(let value): return .groupV1(StorageServiceProtoGroupV1Record(value))
    case .groupV2(let value): return .groupV2(StorageServiceProtoGroupV2Record(value))
    case .account(let value): return .account(StorageServiceProtoAccountRecord(value))
    case .storyDistributionList(let value): return .storyDistributionList(StorageServiceProtoStoryDistributionListRecord(value))
    case .callLink(let value): return .callLink(StorageServiceProtoCallLinkRecord(value))
    }
}

private func StorageServiceProtoStorageRecordOneOfRecordUnwrap(_ value: StorageServiceProtoStorageRecordOneOfRecord) -> StorageServiceProtos_StorageRecord.OneOf_Record {
    switch value {
    case .contact(let value): return .contact(value.proto)
    case .groupV1(let value): return .groupV1(value.proto)
    case .groupV2(let value): return .groupV2(value.proto)
    case .account(let value): return .account(value.proto)
    case .storyDistributionList(let value): return .storyDistributionList(value.proto)
    case .callLink(let value): return .callLink(value.proto)
    }
}

// MARK: - StorageServiceProtoStorageRecord

public struct StorageServiceProtoStorageRecord: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_StorageRecord

    public var record: StorageServiceProtoStorageRecordOneOfRecord? {
        guard let record = proto.record else {
            return nil
        }
        return StorageServiceProtoStorageRecordOneOfRecordWrap(record)
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_StorageRecord) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_StorageRecord(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_StorageRecord) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoStorageRecord {
    public static func builder() -> StorageServiceProtoStorageRecordBuilder {
        return StorageServiceProtoStorageRecordBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoStorageRecordBuilder {
        var builder = StorageServiceProtoStorageRecordBuilder()
        if let _value = record {
            builder.setRecord(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoStorageRecordBuilder {

    private var proto = StorageServiceProtos_StorageRecord()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setRecord(_ valueParam: StorageServiceProtoStorageRecordOneOfRecord?) {
        guard let valueParam = valueParam else { return }
        proto.record = StorageServiceProtoStorageRecordOneOfRecordUnwrap(valueParam)
    }

    public mutating func setRecord(_ valueParam: StorageServiceProtoStorageRecordOneOfRecord) {
        proto.record = StorageServiceProtoStorageRecordOneOfRecordUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoStorageRecord {
        return StorageServiceProtoStorageRecord(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoStorageRecord(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoStorageRecord {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoStorageRecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoStorageRecord? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoContactRecordName

public struct StorageServiceProtoContactRecordName: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_ContactRecord.Name

    public var given: String? {
        guard hasGiven else {
            return nil
        }
        return proto.given
    }
    public var hasGiven: Bool {
        return !proto.given.isEmpty
    }

    public var family: String? {
        guard hasFamily else {
            return nil
        }
        return proto.family
    }
    public var hasFamily: Bool {
        return !proto.family.isEmpty
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_ContactRecord.Name) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_ContactRecord.Name(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_ContactRecord.Name) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoContactRecordName {
    public static func builder() -> StorageServiceProtoContactRecordNameBuilder {
        return StorageServiceProtoContactRecordNameBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoContactRecordNameBuilder {
        var builder = StorageServiceProtoContactRecordNameBuilder()
        if let _value = given {
            builder.setGiven(_value)
        }
        if let _value = family {
            builder.setFamily(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoContactRecordNameBuilder {

    private var proto = StorageServiceProtos_ContactRecord.Name()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setGiven(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.given = valueParam
    }

    public mutating func setGiven(_ valueParam: String) {
        proto.given = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setFamily(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.family = valueParam
    }

    public mutating func setFamily(_ valueParam: String) {
        proto.family = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoContactRecordName {
        return StorageServiceProtoContactRecordName(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoContactRecordName(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoContactRecordName {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoContactRecordNameBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoContactRecordName? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoContactRecordIdentityState

public enum StorageServiceProtoContactRecordIdentityState: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case `default` // 0
    case verified // 1
    case unverified // 2
    case UNRECOGNIZED(Int)

    public init() {
        self = .default
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .default
            case 1: self = .verified
            case 2: self = .unverified
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .default: return 0
            case .verified: return 1
            case .unverified: return 2
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoContactRecordIdentityStateWrap(_ value: StorageServiceProtos_ContactRecord.IdentityState) -> StorageServiceProtoContactRecordIdentityState {
    switch value {
    case .default: return .default
    case .verified: return .verified
    case .unverified: return .unverified
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoContactRecordIdentityStateUnwrap(_ value: StorageServiceProtoContactRecordIdentityState) -> StorageServiceProtos_ContactRecord.IdentityState {
    switch value {
    case .default: return .default
    case .verified: return .verified
    case .unverified: return .unverified
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoContactRecord

public struct StorageServiceProtoContactRecord: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_ContactRecord

    public let nickname: StorageServiceProtoContactRecordName?

    public var aci: String? {
        guard hasAci else {
            return nil
        }
        return proto.aci
    }
    public var hasAci: Bool {
        return !proto.aci.isEmpty
    }

    public var e164: String? {
        guard hasE164 else {
            return nil
        }
        return proto.e164
    }
    public var hasE164: Bool {
        return !proto.e164.isEmpty
    }

    public var pni: String? {
        guard hasPni else {
            return nil
        }
        return proto.pni
    }
    public var hasPni: Bool {
        return !proto.pni.isEmpty
    }

    public var profileKey: Data? {
        guard hasProfileKey else {
            return nil
        }
        return proto.profileKey
    }
    public var hasProfileKey: Bool {
        return !proto.profileKey.isEmpty
    }

    public var identityKey: Data? {
        guard hasIdentityKey else {
            return nil
        }
        return proto.identityKey
    }
    public var hasIdentityKey: Bool {
        return !proto.identityKey.isEmpty
    }

    public var identityState: StorageServiceProtoContactRecordIdentityState {
        return StorageServiceProtoContactRecordIdentityStateWrap(proto.identityState)
    }
    public var givenName: String? {
        guard hasGivenName else {
            return nil
        }
        return proto.givenName
    }
    public var hasGivenName: Bool {
        return !proto.givenName.isEmpty
    }

    public var familyName: String? {
        guard hasFamilyName else {
            return nil
        }
        return proto.familyName
    }
    public var hasFamilyName: Bool {
        return !proto.familyName.isEmpty
    }

    public var username: String? {
        guard hasUsername else {
            return nil
        }
        return proto.username
    }
    public var hasUsername: Bool {
        return !proto.username.isEmpty
    }

    public var blocked: Bool {
        return proto.blocked
    }
    public var whitelisted: Bool {
        return proto.whitelisted
    }
    public var archived: Bool {
        return proto.archived
    }
    public var markedUnread: Bool {
        return proto.markedUnread
    }
    public var mutedUntilTimestamp: UInt64 {
        return proto.mutedUntilTimestamp
    }
    public var hideStory: Bool {
        return proto.hideStory
    }
    public var unregisteredAtTimestamp: UInt64 {
        return proto.unregisteredAtTimestamp
    }
    public var systemGivenName: String? {
        guard hasSystemGivenName else {
            return nil
        }
        return proto.systemGivenName
    }
    public var hasSystemGivenName: Bool {
        return !proto.systemGivenName.isEmpty
    }

    public var systemFamilyName: String? {
        guard hasSystemFamilyName else {
            return nil
        }
        return proto.systemFamilyName
    }
    public var hasSystemFamilyName: Bool {
        return !proto.systemFamilyName.isEmpty
    }

    public var systemNickname: String? {
        guard hasSystemNickname else {
            return nil
        }
        return proto.systemNickname
    }
    public var hasSystemNickname: Bool {
        return !proto.systemNickname.isEmpty
    }

    public var hidden: Bool {
        return proto.hidden
    }
    public var note: String? {
        guard hasNote else {
            return nil
        }
        return proto.note
    }
    public var hasNote: Bool {
        return !proto.note.isEmpty
    }

    public var avatarColor: StorageServiceProtoAvatarColor? {
        guard hasAvatarColor else {
            return nil
        }
        return StorageServiceProtoAvatarColorWrap(proto.avatarColor)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    public var unwrappedAvatarColor: StorageServiceProtoAvatarColor {
        if !hasAvatarColor {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: ContactRecord.avatarColor.")
        }
        return StorageServiceProtoAvatarColorWrap(proto.avatarColor)
    }
    public var hasAvatarColor: Bool {
        return proto.hasAvatarColor
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_ContactRecord,
                 nickname: StorageServiceProtoContactRecordName?) {
        self.proto = proto
        self.nickname = nickname
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_ContactRecord(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_ContactRecord) {
        var nickname: StorageServiceProtoContactRecordName?
        if proto.hasNickname {
            nickname = StorageServiceProtoContactRecordName(proto.nickname)
        }

        self.init(proto: proto,
                  nickname: nickname)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoContactRecord {
    public static func builder() -> StorageServiceProtoContactRecordBuilder {
        return StorageServiceProtoContactRecordBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoContactRecordBuilder {
        var builder = StorageServiceProtoContactRecordBuilder()
        if let _value = aci {
            builder.setAci(_value)
        }
        if let _value = e164 {
            builder.setE164(_value)
        }
        if let _value = pni {
            builder.setPni(_value)
        }
        if let _value = profileKey {
            builder.setProfileKey(_value)
        }
        if let _value = identityKey {
            builder.setIdentityKey(_value)
        }
        builder.setIdentityState(identityState)
        if let _value = givenName {
            builder.setGivenName(_value)
        }
        if let _value = familyName {
            builder.setFamilyName(_value)
        }
        if let _value = username {
            builder.setUsername(_value)
        }
        builder.setBlocked(blocked)
        builder.setWhitelisted(whitelisted)
        builder.setArchived(archived)
        builder.setMarkedUnread(markedUnread)
        builder.setMutedUntilTimestamp(mutedUntilTimestamp)
        builder.setHideStory(hideStory)
        builder.setUnregisteredAtTimestamp(unregisteredAtTimestamp)
        if let _value = systemGivenName {
            builder.setSystemGivenName(_value)
        }
        if let _value = systemFamilyName {
            builder.setSystemFamilyName(_value)
        }
        if let _value = systemNickname {
            builder.setSystemNickname(_value)
        }
        builder.setHidden(hidden)
        if let _value = nickname {
            builder.setNickname(_value)
        }
        if let _value = note {
            builder.setNote(_value)
        }
        if let _value = avatarColor {
            builder.setAvatarColor(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoContactRecordBuilder {

    private var proto = StorageServiceProtos_ContactRecord()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setAci(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.aci = valueParam
    }

    public mutating func setAci(_ valueParam: String) {
        proto.aci = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setE164(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.e164 = valueParam
    }

    public mutating func setE164(_ valueParam: String) {
        proto.e164 = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setPni(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.pni = valueParam
    }

    public mutating func setPni(_ valueParam: String) {
        proto.pni = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setProfileKey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.profileKey = valueParam
    }

    public mutating func setProfileKey(_ valueParam: Data) {
        proto.profileKey = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setIdentityKey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.identityKey = valueParam
    }

    public mutating func setIdentityKey(_ valueParam: Data) {
        proto.identityKey = valueParam
    }

    public mutating func setIdentityState(_ valueParam: StorageServiceProtoContactRecordIdentityState) {
        proto.identityState = StorageServiceProtoContactRecordIdentityStateUnwrap(valueParam)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setGivenName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.givenName = valueParam
    }

    public mutating func setGivenName(_ valueParam: String) {
        proto.givenName = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setFamilyName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.familyName = valueParam
    }

    public mutating func setFamilyName(_ valueParam: String) {
        proto.familyName = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setUsername(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.username = valueParam
    }

    public mutating func setUsername(_ valueParam: String) {
        proto.username = valueParam
    }

    public mutating func setBlocked(_ valueParam: Bool) {
        proto.blocked = valueParam
    }

    public mutating func setWhitelisted(_ valueParam: Bool) {
        proto.whitelisted = valueParam
    }

    public mutating func setArchived(_ valueParam: Bool) {
        proto.archived = valueParam
    }

    public mutating func setMarkedUnread(_ valueParam: Bool) {
        proto.markedUnread = valueParam
    }

    public mutating func setMutedUntilTimestamp(_ valueParam: UInt64) {
        proto.mutedUntilTimestamp = valueParam
    }

    public mutating func setHideStory(_ valueParam: Bool) {
        proto.hideStory = valueParam
    }

    public mutating func setUnregisteredAtTimestamp(_ valueParam: UInt64) {
        proto.unregisteredAtTimestamp = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setSystemGivenName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.systemGivenName = valueParam
    }

    public mutating func setSystemGivenName(_ valueParam: String) {
        proto.systemGivenName = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setSystemFamilyName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.systemFamilyName = valueParam
    }

    public mutating func setSystemFamilyName(_ valueParam: String) {
        proto.systemFamilyName = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setSystemNickname(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.systemNickname = valueParam
    }

    public mutating func setSystemNickname(_ valueParam: String) {
        proto.systemNickname = valueParam
    }

    public mutating func setHidden(_ valueParam: Bool) {
        proto.hidden = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setNickname(_ valueParam: StorageServiceProtoContactRecordName?) {
        guard let valueParam = valueParam else { return }
        proto.nickname = valueParam.proto
    }

    public mutating func setNickname(_ valueParam: StorageServiceProtoContactRecordName) {
        proto.nickname = valueParam.proto
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setNote(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.note = valueParam
    }

    public mutating func setNote(_ valueParam: String) {
        proto.note = valueParam
    }

    public mutating func setAvatarColor(_ valueParam: StorageServiceProtoAvatarColor) {
        proto.avatarColor = StorageServiceProtoAvatarColorUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoContactRecord {
        return StorageServiceProtoContactRecord(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoContactRecord(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoContactRecord {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoContactRecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoContactRecord? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoGroupV1Record

public struct StorageServiceProtoGroupV1Record: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_GroupV1Record

    public let id: Data

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_GroupV1Record,
                 id: Data) {
        self.proto = proto
        self.id = id
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_GroupV1Record(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_GroupV1Record) {
        let id = proto.id

        self.init(proto: proto,
                  id: id)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoGroupV1Record {
    public static func builder(id: Data) -> StorageServiceProtoGroupV1RecordBuilder {
        return StorageServiceProtoGroupV1RecordBuilder(id: id)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoGroupV1RecordBuilder {
        var builder = StorageServiceProtoGroupV1RecordBuilder(id: id)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoGroupV1RecordBuilder {

    private var proto = StorageServiceProtos_GroupV1Record()

    fileprivate init() {}

    fileprivate init(id: Data) {

        setId(id)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setId(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.id = valueParam
    }

    public mutating func setId(_ valueParam: Data) {
        proto.id = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoGroupV1Record {
        return StorageServiceProtoGroupV1Record(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoGroupV1Record(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoGroupV1Record {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoGroupV1RecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoGroupV1Record? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoGroupV2RecordStorySendMode

public enum StorageServiceProtoGroupV2RecordStorySendMode: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case `default` // 0
    case disabled // 1
    case enabled // 2
    case UNRECOGNIZED(Int)

    public init() {
        self = .default
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .default
            case 1: self = .disabled
            case 2: self = .enabled
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .default: return 0
            case .disabled: return 1
            case .enabled: return 2
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoGroupV2RecordStorySendModeWrap(_ value: StorageServiceProtos_GroupV2Record.StorySendMode) -> StorageServiceProtoGroupV2RecordStorySendMode {
    switch value {
    case .default: return .default
    case .disabled: return .disabled
    case .enabled: return .enabled
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoGroupV2RecordStorySendModeUnwrap(_ value: StorageServiceProtoGroupV2RecordStorySendMode) -> StorageServiceProtos_GroupV2Record.StorySendMode {
    switch value {
    case .default: return .default
    case .disabled: return .disabled
    case .enabled: return .enabled
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoGroupV2Record

public struct StorageServiceProtoGroupV2Record: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_GroupV2Record

    public let masterKey: Data

    public var blocked: Bool {
        return proto.blocked
    }
    public var whitelisted: Bool {
        return proto.whitelisted
    }
    public var archived: Bool {
        return proto.archived
    }
    public var markedUnread: Bool {
        return proto.markedUnread
    }
    public var mutedUntilTimestamp: UInt64 {
        return proto.mutedUntilTimestamp
    }
    public var dontNotifyForMentionsIfMuted: Bool {
        return proto.dontNotifyForMentionsIfMuted
    }
    public var hideStory: Bool {
        return proto.hideStory
    }
    public var storySendMode: StorageServiceProtoGroupV2RecordStorySendMode {
        return StorageServiceProtoGroupV2RecordStorySendModeWrap(proto.storySendMode)
    }
    public var avatarColor: StorageServiceProtoAvatarColor? {
        guard hasAvatarColor else {
            return nil
        }
        return StorageServiceProtoAvatarColorWrap(proto.avatarColor)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    public var unwrappedAvatarColor: StorageServiceProtoAvatarColor {
        if !hasAvatarColor {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: GroupV2Record.avatarColor.")
        }
        return StorageServiceProtoAvatarColorWrap(proto.avatarColor)
    }
    public var hasAvatarColor: Bool {
        return proto.hasAvatarColor
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_GroupV2Record,
                 masterKey: Data) {
        self.proto = proto
        self.masterKey = masterKey
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_GroupV2Record(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_GroupV2Record) {
        let masterKey = proto.masterKey

        self.init(proto: proto,
                  masterKey: masterKey)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoGroupV2Record {
    public static func builder(masterKey: Data) -> StorageServiceProtoGroupV2RecordBuilder {
        return StorageServiceProtoGroupV2RecordBuilder(masterKey: masterKey)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoGroupV2RecordBuilder {
        var builder = StorageServiceProtoGroupV2RecordBuilder(masterKey: masterKey)
        builder.setBlocked(blocked)
        builder.setWhitelisted(whitelisted)
        builder.setArchived(archived)
        builder.setMarkedUnread(markedUnread)
        builder.setMutedUntilTimestamp(mutedUntilTimestamp)
        builder.setDontNotifyForMentionsIfMuted(dontNotifyForMentionsIfMuted)
        builder.setHideStory(hideStory)
        builder.setStorySendMode(storySendMode)
        if let _value = avatarColor {
            builder.setAvatarColor(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoGroupV2RecordBuilder {

    private var proto = StorageServiceProtos_GroupV2Record()

    fileprivate init() {}

    fileprivate init(masterKey: Data) {

        setMasterKey(masterKey)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setMasterKey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.masterKey = valueParam
    }

    public mutating func setMasterKey(_ valueParam: Data) {
        proto.masterKey = valueParam
    }

    public mutating func setBlocked(_ valueParam: Bool) {
        proto.blocked = valueParam
    }

    public mutating func setWhitelisted(_ valueParam: Bool) {
        proto.whitelisted = valueParam
    }

    public mutating func setArchived(_ valueParam: Bool) {
        proto.archived = valueParam
    }

    public mutating func setMarkedUnread(_ valueParam: Bool) {
        proto.markedUnread = valueParam
    }

    public mutating func setMutedUntilTimestamp(_ valueParam: UInt64) {
        proto.mutedUntilTimestamp = valueParam
    }

    public mutating func setDontNotifyForMentionsIfMuted(_ valueParam: Bool) {
        proto.dontNotifyForMentionsIfMuted = valueParam
    }

    public mutating func setHideStory(_ valueParam: Bool) {
        proto.hideStory = valueParam
    }

    public mutating func setStorySendMode(_ valueParam: StorageServiceProtoGroupV2RecordStorySendMode) {
        proto.storySendMode = StorageServiceProtoGroupV2RecordStorySendModeUnwrap(valueParam)
    }

    public mutating func setAvatarColor(_ valueParam: StorageServiceProtoAvatarColor) {
        proto.avatarColor = StorageServiceProtoAvatarColorUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoGroupV2Record {
        return StorageServiceProtoGroupV2Record(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoGroupV2Record(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoGroupV2Record {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoGroupV2RecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoGroupV2Record? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoAccountRecordPinnedConversationContact

public struct StorageServiceProtoAccountRecordPinnedConversationContact: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_AccountRecord.PinnedConversation.Contact

    public var serviceID: String? {
        guard hasServiceID else {
            return nil
        }
        return proto.serviceID
    }
    public var hasServiceID: Bool {
        return !proto.serviceID.isEmpty
    }

    public var e164: String? {
        guard hasE164 else {
            return nil
        }
        return proto.e164
    }
    public var hasE164: Bool {
        return !proto.e164.isEmpty
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_AccountRecord.PinnedConversation.Contact) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_AccountRecord.PinnedConversation.Contact(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_AccountRecord.PinnedConversation.Contact) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoAccountRecordPinnedConversationContact {
    public static func builder() -> StorageServiceProtoAccountRecordPinnedConversationContactBuilder {
        return StorageServiceProtoAccountRecordPinnedConversationContactBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoAccountRecordPinnedConversationContactBuilder {
        var builder = StorageServiceProtoAccountRecordPinnedConversationContactBuilder()
        if let _value = serviceID {
            builder.setServiceID(_value)
        }
        if let _value = e164 {
            builder.setE164(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoAccountRecordPinnedConversationContactBuilder {

    private var proto = StorageServiceProtos_AccountRecord.PinnedConversation.Contact()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setServiceID(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.serviceID = valueParam
    }

    public mutating func setServiceID(_ valueParam: String) {
        proto.serviceID = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setE164(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.e164 = valueParam
    }

    public mutating func setE164(_ valueParam: String) {
        proto.e164 = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoAccountRecordPinnedConversationContact {
        return StorageServiceProtoAccountRecordPinnedConversationContact(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoAccountRecordPinnedConversationContact(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoAccountRecordPinnedConversationContact {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoAccountRecordPinnedConversationContactBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoAccountRecordPinnedConversationContact? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier

public enum StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier {
    case contact(StorageServiceProtoAccountRecordPinnedConversationContact)
    case legacyGroupID(Data)
    case groupMasterKey(Data)
}

private func StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifierWrap(_ value: StorageServiceProtos_AccountRecord.PinnedConversation.OneOf_Identifier) -> StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier {
    switch value {
    case .contact(let value): return .contact(StorageServiceProtoAccountRecordPinnedConversationContact(value))
    case .legacyGroupID(let value): return .legacyGroupID(value)
    case .groupMasterKey(let value): return .groupMasterKey(value)
    }
}

private func StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifierUnwrap(_ value: StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier) -> StorageServiceProtos_AccountRecord.PinnedConversation.OneOf_Identifier {
    switch value {
    case .contact(let value): return .contact(value.proto)
    case .legacyGroupID(let value): return .legacyGroupID(value)
    case .groupMasterKey(let value): return .groupMasterKey(value)
    }
}

// MARK: - StorageServiceProtoAccountRecordPinnedConversation

public struct StorageServiceProtoAccountRecordPinnedConversation: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_AccountRecord.PinnedConversation

    public var identifier: StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier? {
        guard let identifier = proto.identifier else {
            return nil
        }
        return StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifierWrap(identifier)
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_AccountRecord.PinnedConversation) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_AccountRecord.PinnedConversation(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_AccountRecord.PinnedConversation) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoAccountRecordPinnedConversation {
    public static func builder() -> StorageServiceProtoAccountRecordPinnedConversationBuilder {
        return StorageServiceProtoAccountRecordPinnedConversationBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoAccountRecordPinnedConversationBuilder {
        var builder = StorageServiceProtoAccountRecordPinnedConversationBuilder()
        if let _value = identifier {
            builder.setIdentifier(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoAccountRecordPinnedConversationBuilder {

    private var proto = StorageServiceProtos_AccountRecord.PinnedConversation()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setIdentifier(_ valueParam: StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier?) {
        guard let valueParam = valueParam else { return }
        proto.identifier = StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifierUnwrap(valueParam)
    }

    public mutating func setIdentifier(_ valueParam: StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifier) {
        proto.identifier = StorageServiceProtoAccountRecordPinnedConversationOneOfIdentifierUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoAccountRecordPinnedConversation {
        return StorageServiceProtoAccountRecordPinnedConversation(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoAccountRecordPinnedConversation(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoAccountRecordPinnedConversation {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoAccountRecordPinnedConversationBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoAccountRecordPinnedConversation? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoAccountRecordPayments

public struct StorageServiceProtoAccountRecordPayments: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_AccountRecord.Payments

    public var enabled: Bool {
        return proto.enabled
    }
    public var paymentsEntropy: Data? {
        guard hasPaymentsEntropy else {
            return nil
        }
        return proto.paymentsEntropy
    }
    public var hasPaymentsEntropy: Bool {
        return !proto.paymentsEntropy.isEmpty
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_AccountRecord.Payments) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_AccountRecord.Payments(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_AccountRecord.Payments) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoAccountRecordPayments {
    public static func builder() -> StorageServiceProtoAccountRecordPaymentsBuilder {
        return StorageServiceProtoAccountRecordPaymentsBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoAccountRecordPaymentsBuilder {
        var builder = StorageServiceProtoAccountRecordPaymentsBuilder()
        builder.setEnabled(enabled)
        if let _value = paymentsEntropy {
            builder.setPaymentsEntropy(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoAccountRecordPaymentsBuilder {

    private var proto = StorageServiceProtos_AccountRecord.Payments()

    fileprivate init() {}

    public mutating func setEnabled(_ valueParam: Bool) {
        proto.enabled = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setPaymentsEntropy(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.paymentsEntropy = valueParam
    }

    public mutating func setPaymentsEntropy(_ valueParam: Data) {
        proto.paymentsEntropy = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoAccountRecordPayments {
        return StorageServiceProtoAccountRecordPayments(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoAccountRecordPayments(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoAccountRecordPayments {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoAccountRecordPaymentsBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoAccountRecordPayments? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoAccountRecordUsernameLinkColor

public enum StorageServiceProtoAccountRecordUsernameLinkColor: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unknown // 0
    case blue // 1
    case white // 2
    case grey // 3
    case olive // 4
    case green // 5
    case orange // 6
    case pink // 7
    case purple // 8
    case UNRECOGNIZED(Int)

    public init() {
        self = .unknown
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .unknown
            case 1: self = .blue
            case 2: self = .white
            case 3: self = .grey
            case 4: self = .olive
            case 5: self = .green
            case 6: self = .orange
            case 7: self = .pink
            case 8: self = .purple
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .unknown: return 0
            case .blue: return 1
            case .white: return 2
            case .grey: return 3
            case .olive: return 4
            case .green: return 5
            case .orange: return 6
            case .pink: return 7
            case .purple: return 8
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoAccountRecordUsernameLinkColorWrap(_ value: StorageServiceProtos_AccountRecord.UsernameLink.Color) -> StorageServiceProtoAccountRecordUsernameLinkColor {
    switch value {
    case .unknown: return .unknown
    case .blue: return .blue
    case .white: return .white
    case .grey: return .grey
    case .olive: return .olive
    case .green: return .green
    case .orange: return .orange
    case .pink: return .pink
    case .purple: return .purple
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoAccountRecordUsernameLinkColorUnwrap(_ value: StorageServiceProtoAccountRecordUsernameLinkColor) -> StorageServiceProtos_AccountRecord.UsernameLink.Color {
    switch value {
    case .unknown: return .unknown
    case .blue: return .blue
    case .white: return .white
    case .grey: return .grey
    case .olive: return .olive
    case .green: return .green
    case .orange: return .orange
    case .pink: return .pink
    case .purple: return .purple
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoAccountRecordUsernameLink

public struct StorageServiceProtoAccountRecordUsernameLink: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_AccountRecord.UsernameLink

    public var entropy: Data? {
        guard hasEntropy else {
            return nil
        }
        return proto.entropy
    }
    public var hasEntropy: Bool {
        return !proto.entropy.isEmpty
    }

    public var serverID: Data? {
        guard hasServerID else {
            return nil
        }
        return proto.serverID
    }
    public var hasServerID: Bool {
        return !proto.serverID.isEmpty
    }

    public var color: StorageServiceProtoAccountRecordUsernameLinkColor {
        return StorageServiceProtoAccountRecordUsernameLinkColorWrap(proto.color)
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_AccountRecord.UsernameLink) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_AccountRecord.UsernameLink(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_AccountRecord.UsernameLink) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoAccountRecordUsernameLink {
    public static func builder() -> StorageServiceProtoAccountRecordUsernameLinkBuilder {
        return StorageServiceProtoAccountRecordUsernameLinkBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoAccountRecordUsernameLinkBuilder {
        var builder = StorageServiceProtoAccountRecordUsernameLinkBuilder()
        if let _value = entropy {
            builder.setEntropy(_value)
        }
        if let _value = serverID {
            builder.setServerID(_value)
        }
        builder.setColor(color)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoAccountRecordUsernameLinkBuilder {

    private var proto = StorageServiceProtos_AccountRecord.UsernameLink()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setEntropy(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.entropy = valueParam
    }

    public mutating func setEntropy(_ valueParam: Data) {
        proto.entropy = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setServerID(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.serverID = valueParam
    }

    public mutating func setServerID(_ valueParam: Data) {
        proto.serverID = valueParam
    }

    public mutating func setColor(_ valueParam: StorageServiceProtoAccountRecordUsernameLinkColor) {
        proto.color = StorageServiceProtoAccountRecordUsernameLinkColorUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoAccountRecordUsernameLink {
        return StorageServiceProtoAccountRecordUsernameLink(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoAccountRecordUsernameLink(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoAccountRecordUsernameLink {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoAccountRecordUsernameLinkBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoAccountRecordUsernameLink? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID

public enum StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID {
    case purchaseToken(String)
    case originalTransactionID(UInt64)
}

private func StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionIDWrap(_ value: StorageServiceProtos_AccountRecord.IAPSubscriberData.OneOf_IapSubscriptionID) -> StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID {
    switch value {
    case .purchaseToken(let value): return .purchaseToken(value)
    case .originalTransactionID(let value): return .originalTransactionID(value)
    }
}

private func StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionIDUnwrap(_ value: StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID) -> StorageServiceProtos_AccountRecord.IAPSubscriberData.OneOf_IapSubscriptionID {
    switch value {
    case .purchaseToken(let value): return .purchaseToken(value)
    case .originalTransactionID(let value): return .originalTransactionID(value)
    }
}

// MARK: - StorageServiceProtoAccountRecordIAPSubscriberData

public struct StorageServiceProtoAccountRecordIAPSubscriberData: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_AccountRecord.IAPSubscriberData

    public var subscriberID: Data? {
        guard hasSubscriberID else {
            return nil
        }
        return proto.subscriberID
    }
    public var hasSubscriberID: Bool {
        return !proto.subscriberID.isEmpty
    }

    public var iapSubscriptionID: StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID? {
        guard let iapSubscriptionID = proto.iapSubscriptionID else {
            return nil
        }
        return StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionIDWrap(iapSubscriptionID)
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_AccountRecord.IAPSubscriberData) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_AccountRecord.IAPSubscriberData(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_AccountRecord.IAPSubscriberData) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoAccountRecordIAPSubscriberData {
    public static func builder() -> StorageServiceProtoAccountRecordIAPSubscriberDataBuilder {
        return StorageServiceProtoAccountRecordIAPSubscriberDataBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoAccountRecordIAPSubscriberDataBuilder {
        var builder = StorageServiceProtoAccountRecordIAPSubscriberDataBuilder()
        if let _value = subscriberID {
            builder.setSubscriberID(_value)
        }
        if let _value = iapSubscriptionID {
            builder.setIapSubscriptionID(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoAccountRecordIAPSubscriberDataBuilder {

    private var proto = StorageServiceProtos_AccountRecord.IAPSubscriberData()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setSubscriberID(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.subscriberID = valueParam
    }

    public mutating func setSubscriberID(_ valueParam: Data) {
        proto.subscriberID = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setIapSubscriptionID(_ valueParam: StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID?) {
        guard let valueParam = valueParam else { return }
        proto.iapSubscriptionID = StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionIDUnwrap(valueParam)
    }

    public mutating func setIapSubscriptionID(_ valueParam: StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionID) {
        proto.iapSubscriptionID = StorageServiceProtoAccountRecordIAPSubscriberDataOneOfIapSubscriptionIDUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoAccountRecordIAPSubscriberData {
        return StorageServiceProtoAccountRecordIAPSubscriberData(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoAccountRecordIAPSubscriberData(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoAccountRecordIAPSubscriberData {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoAccountRecordIAPSubscriberDataBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoAccountRecordIAPSubscriberData? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoAccountRecordPhoneNumberSharingMode

public enum StorageServiceProtoAccountRecordPhoneNumberSharingMode: SwiftProtobuf.Enum {
    public typealias RawValue = Int
    case unknown // 0
    case everybody // 1
    case nobody // 2
    case UNRECOGNIZED(Int)

    public init() {
        self = .unknown
    }

    public init?(rawValue: Int) {
        switch rawValue {
            case 0: self = .unknown
            case 1: self = .everybody
            case 2: self = .nobody
            default: self = .UNRECOGNIZED(rawValue)
        }
    }

    public var rawValue: Int {
        switch self {
            case .unknown: return 0
            case .everybody: return 1
            case .nobody: return 2
            case .UNRECOGNIZED(let i): return i
        }
    }
}

private func StorageServiceProtoAccountRecordPhoneNumberSharingModeWrap(_ value: StorageServiceProtos_AccountRecord.PhoneNumberSharingMode) -> StorageServiceProtoAccountRecordPhoneNumberSharingMode {
    switch value {
    case .unknown: return .unknown
    case .everybody: return .everybody
    case .nobody: return .nobody
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

private func StorageServiceProtoAccountRecordPhoneNumberSharingModeUnwrap(_ value: StorageServiceProtoAccountRecordPhoneNumberSharingMode) -> StorageServiceProtos_AccountRecord.PhoneNumberSharingMode {
    switch value {
    case .unknown: return .unknown
    case .everybody: return .everybody
    case .nobody: return .nobody
    case .UNRECOGNIZED(let i): return .UNRECOGNIZED(i)
    }
}

// MARK: - StorageServiceProtoAccountRecord

public struct StorageServiceProtoAccountRecord: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_AccountRecord

    public let pinnedConversations: [StorageServiceProtoAccountRecordPinnedConversation]

    public let payments: StorageServiceProtoAccountRecordPayments?

    public let usernameLink: StorageServiceProtoAccountRecordUsernameLink?

    public let backupSubscriberData: StorageServiceProtoAccountRecordIAPSubscriberData?

    public var profileKey: Data? {
        guard hasProfileKey else {
            return nil
        }
        return proto.profileKey
    }
    public var hasProfileKey: Bool {
        return !proto.profileKey.isEmpty
    }

    public var givenName: String? {
        guard hasGivenName else {
            return nil
        }
        return proto.givenName
    }
    public var hasGivenName: Bool {
        return !proto.givenName.isEmpty
    }

    public var familyName: String? {
        guard hasFamilyName else {
            return nil
        }
        return proto.familyName
    }
    public var hasFamilyName: Bool {
        return !proto.familyName.isEmpty
    }

    public var avatarURL: String? {
        guard hasAvatarURL else {
            return nil
        }
        return proto.avatarURL
    }
    public var hasAvatarURL: Bool {
        return !proto.avatarURL.isEmpty
    }

    public var noteToSelfArchived: Bool {
        return proto.noteToSelfArchived
    }
    public var readReceipts: Bool {
        return proto.readReceipts
    }
    public var sealedSenderIndicators: Bool {
        return proto.sealedSenderIndicators
    }
    public var typingIndicators: Bool {
        return proto.typingIndicators
    }
    public var proxiedLinkPreviews: Bool {
        return proto.proxiedLinkPreviews
    }
    public var noteToSelfMarkedUnread: Bool {
        return proto.noteToSelfMarkedUnread
    }
    public var linkPreviews: Bool {
        return proto.linkPreviews
    }
    public var phoneNumberSharingMode: StorageServiceProtoAccountRecordPhoneNumberSharingMode {
        return StorageServiceProtoAccountRecordPhoneNumberSharingModeWrap(proto.phoneNumberSharingMode)
    }
    public var notDiscoverableByPhoneNumber: Bool {
        return proto.notDiscoverableByPhoneNumber
    }
    public var preferContactAvatars: Bool {
        return proto.preferContactAvatars
    }
    public var universalExpireTimer: UInt32 {
        return proto.universalExpireTimer
    }
    public var e164: String? {
        guard hasE164 else {
            return nil
        }
        return proto.e164
    }
    public var hasE164: Bool {
        return !proto.e164.isEmpty
    }

    public var preferredReactionEmoji: [String] {
        return proto.preferredReactionEmoji
    }

    public var donorSubscriberID: Data? {
        guard hasDonorSubscriberID else {
            return nil
        }
        return proto.donorSubscriberID
    }
    public var hasDonorSubscriberID: Bool {
        return !proto.donorSubscriberID.isEmpty
    }

    public var donorSubscriberCurrencyCode: String? {
        guard hasDonorSubscriberCurrencyCode else {
            return nil
        }
        return proto.donorSubscriberCurrencyCode
    }
    public var hasDonorSubscriberCurrencyCode: Bool {
        return !proto.donorSubscriberCurrencyCode.isEmpty
    }

    public var displayBadgesOnProfile: Bool {
        return proto.displayBadgesOnProfile
    }
    public var donorSubscriptionManuallyCancelled: Bool {
        return proto.donorSubscriptionManuallyCancelled
    }
    public var keepMutedChatsArchived: Bool {
        return proto.keepMutedChatsArchived
    }
    public var myStoryPrivacyHasBeenSet: Bool {
        return proto.myStoryPrivacyHasBeenSet
    }
    public var viewedOnboardingStory: Bool {
        return proto.viewedOnboardingStory
    }
    public var storiesDisabled: Bool {
        return proto.storiesDisabled
    }
    public var storyViewReceiptsEnabled: StorageServiceProtoOptionalBool {
        return StorageServiceProtoOptionalBoolWrap(proto.storyViewReceiptsEnabled)
    }
    public var readOnboardingStory: Bool {
        return proto.readOnboardingStory
    }
    public var username: String? {
        guard hasUsername else {
            return nil
        }
        return proto.username
    }
    public var hasUsername: Bool {
        return !proto.username.isEmpty
    }

    public var completedUsernameOnboarding: Bool {
        return proto.completedUsernameOnboarding
    }
    public var avatarColor: StorageServiceProtoAvatarColor? {
        guard hasAvatarColor else {
            return nil
        }
        return StorageServiceProtoAvatarColorWrap(proto.avatarColor)
    }
    // This "unwrapped" accessor should only be used if the "has value" accessor has already been checked.
    public var unwrappedAvatarColor: StorageServiceProtoAvatarColor {
        if !hasAvatarColor {
            // TODO: We could make this a crashing assert.
            owsFailDebug("Unsafe unwrap of missing optional: AccountRecord.avatarColor.")
        }
        return StorageServiceProtoAvatarColorWrap(proto.avatarColor)
    }
    public var hasAvatarColor: Bool {
        return proto.hasAvatarColor
    }

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_AccountRecord,
                 pinnedConversations: [StorageServiceProtoAccountRecordPinnedConversation],
                 payments: StorageServiceProtoAccountRecordPayments?,
                 usernameLink: StorageServiceProtoAccountRecordUsernameLink?,
                 backupSubscriberData: StorageServiceProtoAccountRecordIAPSubscriberData?) {
        self.proto = proto
        self.pinnedConversations = pinnedConversations
        self.payments = payments
        self.usernameLink = usernameLink
        self.backupSubscriberData = backupSubscriberData
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_AccountRecord(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_AccountRecord) {
        var pinnedConversations: [StorageServiceProtoAccountRecordPinnedConversation] = []
        pinnedConversations = proto.pinnedConversations.map { StorageServiceProtoAccountRecordPinnedConversation($0) }

        var payments: StorageServiceProtoAccountRecordPayments?
        if proto.hasPayments {
            payments = StorageServiceProtoAccountRecordPayments(proto.payments)
        }

        var usernameLink: StorageServiceProtoAccountRecordUsernameLink?
        if proto.hasUsernameLink {
            usernameLink = StorageServiceProtoAccountRecordUsernameLink(proto.usernameLink)
        }

        var backupSubscriberData: StorageServiceProtoAccountRecordIAPSubscriberData?
        if proto.hasBackupSubscriberData {
            backupSubscriberData = StorageServiceProtoAccountRecordIAPSubscriberData(proto.backupSubscriberData)
        }

        self.init(proto: proto,
                  pinnedConversations: pinnedConversations,
                  payments: payments,
                  usernameLink: usernameLink,
                  backupSubscriberData: backupSubscriberData)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoAccountRecord {
    public static func builder() -> StorageServiceProtoAccountRecordBuilder {
        return StorageServiceProtoAccountRecordBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoAccountRecordBuilder {
        var builder = StorageServiceProtoAccountRecordBuilder()
        if let _value = profileKey {
            builder.setProfileKey(_value)
        }
        if let _value = givenName {
            builder.setGivenName(_value)
        }
        if let _value = familyName {
            builder.setFamilyName(_value)
        }
        if let _value = avatarURL {
            builder.setAvatarURL(_value)
        }
        builder.setNoteToSelfArchived(noteToSelfArchived)
        builder.setReadReceipts(readReceipts)
        builder.setSealedSenderIndicators(sealedSenderIndicators)
        builder.setTypingIndicators(typingIndicators)
        builder.setProxiedLinkPreviews(proxiedLinkPreviews)
        builder.setNoteToSelfMarkedUnread(noteToSelfMarkedUnread)
        builder.setLinkPreviews(linkPreviews)
        builder.setPhoneNumberSharingMode(phoneNumberSharingMode)
        builder.setNotDiscoverableByPhoneNumber(notDiscoverableByPhoneNumber)
        builder.setPinnedConversations(pinnedConversations)
        builder.setPreferContactAvatars(preferContactAvatars)
        if let _value = payments {
            builder.setPayments(_value)
        }
        builder.setUniversalExpireTimer(universalExpireTimer)
        if let _value = e164 {
            builder.setE164(_value)
        }
        builder.setPreferredReactionEmoji(preferredReactionEmoji)
        if let _value = donorSubscriberID {
            builder.setDonorSubscriberID(_value)
        }
        if let _value = donorSubscriberCurrencyCode {
            builder.setDonorSubscriberCurrencyCode(_value)
        }
        builder.setDisplayBadgesOnProfile(displayBadgesOnProfile)
        builder.setDonorSubscriptionManuallyCancelled(donorSubscriptionManuallyCancelled)
        builder.setKeepMutedChatsArchived(keepMutedChatsArchived)
        builder.setMyStoryPrivacyHasBeenSet(myStoryPrivacyHasBeenSet)
        builder.setViewedOnboardingStory(viewedOnboardingStory)
        builder.setStoriesDisabled(storiesDisabled)
        builder.setStoryViewReceiptsEnabled(storyViewReceiptsEnabled)
        builder.setReadOnboardingStory(readOnboardingStory)
        if let _value = username {
            builder.setUsername(_value)
        }
        builder.setCompletedUsernameOnboarding(completedUsernameOnboarding)
        if let _value = usernameLink {
            builder.setUsernameLink(_value)
        }
        if let _value = backupSubscriberData {
            builder.setBackupSubscriberData(_value)
        }
        if let _value = avatarColor {
            builder.setAvatarColor(_value)
        }
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoAccountRecordBuilder {

    private var proto = StorageServiceProtos_AccountRecord()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setProfileKey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.profileKey = valueParam
    }

    public mutating func setProfileKey(_ valueParam: Data) {
        proto.profileKey = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setGivenName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.givenName = valueParam
    }

    public mutating func setGivenName(_ valueParam: String) {
        proto.givenName = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setFamilyName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.familyName = valueParam
    }

    public mutating func setFamilyName(_ valueParam: String) {
        proto.familyName = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setAvatarURL(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.avatarURL = valueParam
    }

    public mutating func setAvatarURL(_ valueParam: String) {
        proto.avatarURL = valueParam
    }

    public mutating func setNoteToSelfArchived(_ valueParam: Bool) {
        proto.noteToSelfArchived = valueParam
    }

    public mutating func setReadReceipts(_ valueParam: Bool) {
        proto.readReceipts = valueParam
    }

    public mutating func setSealedSenderIndicators(_ valueParam: Bool) {
        proto.sealedSenderIndicators = valueParam
    }

    public mutating func setTypingIndicators(_ valueParam: Bool) {
        proto.typingIndicators = valueParam
    }

    public mutating func setProxiedLinkPreviews(_ valueParam: Bool) {
        proto.proxiedLinkPreviews = valueParam
    }

    public mutating func setNoteToSelfMarkedUnread(_ valueParam: Bool) {
        proto.noteToSelfMarkedUnread = valueParam
    }

    public mutating func setLinkPreviews(_ valueParam: Bool) {
        proto.linkPreviews = valueParam
    }

    public mutating func setPhoneNumberSharingMode(_ valueParam: StorageServiceProtoAccountRecordPhoneNumberSharingMode) {
        proto.phoneNumberSharingMode = StorageServiceProtoAccountRecordPhoneNumberSharingModeUnwrap(valueParam)
    }

    public mutating func setNotDiscoverableByPhoneNumber(_ valueParam: Bool) {
        proto.notDiscoverableByPhoneNumber = valueParam
    }

    public mutating func addPinnedConversations(_ valueParam: StorageServiceProtoAccountRecordPinnedConversation) {
        proto.pinnedConversations.append(valueParam.proto)
    }

    public mutating func setPinnedConversations(_ wrappedItems: [StorageServiceProtoAccountRecordPinnedConversation]) {
        proto.pinnedConversations = wrappedItems.map { $0.proto }
    }

    public mutating func setPreferContactAvatars(_ valueParam: Bool) {
        proto.preferContactAvatars = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setPayments(_ valueParam: StorageServiceProtoAccountRecordPayments?) {
        guard let valueParam = valueParam else { return }
        proto.payments = valueParam.proto
    }

    public mutating func setPayments(_ valueParam: StorageServiceProtoAccountRecordPayments) {
        proto.payments = valueParam.proto
    }

    public mutating func setUniversalExpireTimer(_ valueParam: UInt32) {
        proto.universalExpireTimer = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setE164(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.e164 = valueParam
    }

    public mutating func setE164(_ valueParam: String) {
        proto.e164 = valueParam
    }

    public mutating func addPreferredReactionEmoji(_ valueParam: String) {
        proto.preferredReactionEmoji.append(valueParam)
    }

    public mutating func setPreferredReactionEmoji(_ wrappedItems: [String]) {
        proto.preferredReactionEmoji = wrappedItems
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setDonorSubscriberID(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.donorSubscriberID = valueParam
    }

    public mutating func setDonorSubscriberID(_ valueParam: Data) {
        proto.donorSubscriberID = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setDonorSubscriberCurrencyCode(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.donorSubscriberCurrencyCode = valueParam
    }

    public mutating func setDonorSubscriberCurrencyCode(_ valueParam: String) {
        proto.donorSubscriberCurrencyCode = valueParam
    }

    public mutating func setDisplayBadgesOnProfile(_ valueParam: Bool) {
        proto.displayBadgesOnProfile = valueParam
    }

    public mutating func setDonorSubscriptionManuallyCancelled(_ valueParam: Bool) {
        proto.donorSubscriptionManuallyCancelled = valueParam
    }

    public mutating func setKeepMutedChatsArchived(_ valueParam: Bool) {
        proto.keepMutedChatsArchived = valueParam
    }

    public mutating func setMyStoryPrivacyHasBeenSet(_ valueParam: Bool) {
        proto.myStoryPrivacyHasBeenSet = valueParam
    }

    public mutating func setViewedOnboardingStory(_ valueParam: Bool) {
        proto.viewedOnboardingStory = valueParam
    }

    public mutating func setStoriesDisabled(_ valueParam: Bool) {
        proto.storiesDisabled = valueParam
    }

    public mutating func setStoryViewReceiptsEnabled(_ valueParam: StorageServiceProtoOptionalBool) {
        proto.storyViewReceiptsEnabled = StorageServiceProtoOptionalBoolUnwrap(valueParam)
    }

    public mutating func setReadOnboardingStory(_ valueParam: Bool) {
        proto.readOnboardingStory = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setUsername(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.username = valueParam
    }

    public mutating func setUsername(_ valueParam: String) {
        proto.username = valueParam
    }

    public mutating func setCompletedUsernameOnboarding(_ valueParam: Bool) {
        proto.completedUsernameOnboarding = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setUsernameLink(_ valueParam: StorageServiceProtoAccountRecordUsernameLink?) {
        guard let valueParam = valueParam else { return }
        proto.usernameLink = valueParam.proto
    }

    public mutating func setUsernameLink(_ valueParam: StorageServiceProtoAccountRecordUsernameLink) {
        proto.usernameLink = valueParam.proto
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setBackupSubscriberData(_ valueParam: StorageServiceProtoAccountRecordIAPSubscriberData?) {
        guard let valueParam = valueParam else { return }
        proto.backupSubscriberData = valueParam.proto
    }

    public mutating func setBackupSubscriberData(_ valueParam: StorageServiceProtoAccountRecordIAPSubscriberData) {
        proto.backupSubscriberData = valueParam.proto
    }

    public mutating func setAvatarColor(_ valueParam: StorageServiceProtoAvatarColor) {
        proto.avatarColor = StorageServiceProtoAvatarColorUnwrap(valueParam)
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoAccountRecord {
        return StorageServiceProtoAccountRecord(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoAccountRecord(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoAccountRecord {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoAccountRecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoAccountRecord? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoStoryDistributionListRecord

public struct StorageServiceProtoStoryDistributionListRecord: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_StoryDistributionListRecord

    public var identifier: Data? {
        guard hasIdentifier else {
            return nil
        }
        return proto.identifier
    }
    public var hasIdentifier: Bool {
        return !proto.identifier.isEmpty
    }

    public var name: String? {
        guard hasName else {
            return nil
        }
        return proto.name
    }
    public var hasName: Bool {
        return !proto.name.isEmpty
    }

    public var recipientServiceIds: [String] {
        return proto.recipientServiceIds
    }

    public var deletedAtTimestamp: UInt64 {
        return proto.deletedAtTimestamp
    }
    public var allowsReplies: Bool {
        return proto.allowsReplies
    }
    public var isBlockList: Bool {
        return proto.isBlockList
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_StoryDistributionListRecord) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_StoryDistributionListRecord(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_StoryDistributionListRecord) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoStoryDistributionListRecord {
    public static func builder() -> StorageServiceProtoStoryDistributionListRecordBuilder {
        return StorageServiceProtoStoryDistributionListRecordBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoStoryDistributionListRecordBuilder {
        var builder = StorageServiceProtoStoryDistributionListRecordBuilder()
        if let _value = identifier {
            builder.setIdentifier(_value)
        }
        if let _value = name {
            builder.setName(_value)
        }
        builder.setRecipientServiceIds(recipientServiceIds)
        builder.setDeletedAtTimestamp(deletedAtTimestamp)
        builder.setAllowsReplies(allowsReplies)
        builder.setIsBlockList(isBlockList)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoStoryDistributionListRecordBuilder {

    private var proto = StorageServiceProtos_StoryDistributionListRecord()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setIdentifier(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.identifier = valueParam
    }

    public mutating func setIdentifier(_ valueParam: Data) {
        proto.identifier = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setName(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.name = valueParam
    }

    public mutating func setName(_ valueParam: String) {
        proto.name = valueParam
    }

    public mutating func addRecipientServiceIds(_ valueParam: String) {
        proto.recipientServiceIds.append(valueParam)
    }

    public mutating func setRecipientServiceIds(_ wrappedItems: [String]) {
        proto.recipientServiceIds = wrappedItems
    }

    public mutating func setDeletedAtTimestamp(_ valueParam: UInt64) {
        proto.deletedAtTimestamp = valueParam
    }

    public mutating func setAllowsReplies(_ valueParam: Bool) {
        proto.allowsReplies = valueParam
    }

    public mutating func setIsBlockList(_ valueParam: Bool) {
        proto.isBlockList = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoStoryDistributionListRecord {
        return StorageServiceProtoStoryDistributionListRecord(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoStoryDistributionListRecord(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoStoryDistributionListRecord {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoStoryDistributionListRecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoStoryDistributionListRecord? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - StorageServiceProtoCallLinkRecord

public struct StorageServiceProtoCallLinkRecord: Codable, CustomDebugStringConvertible {

    fileprivate let proto: StorageServiceProtos_CallLinkRecord

    public var rootKey: Data? {
        guard hasRootKey else {
            return nil
        }
        return proto.rootKey
    }
    public var hasRootKey: Bool {
        return !proto.rootKey.isEmpty
    }

    public var adminPasskey: Data? {
        guard hasAdminPasskey else {
            return nil
        }
        return proto.adminPasskey
    }
    public var hasAdminPasskey: Bool {
        return !proto.adminPasskey.isEmpty
    }

    public var deletedAtTimestampMs: UInt64 {
        return proto.deletedAtTimestampMs
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: StorageServiceProtos_CallLinkRecord) {
        self.proto = proto
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try StorageServiceProtos_CallLinkRecord(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: StorageServiceProtos_CallLinkRecord) {
        self.init(proto: proto)
    }

    public init(from decoder: Swift.Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let serializedData = try singleValueContainer.decode(Data.self)
        try self.init(serializedData: serializedData)
    }
    public func encode(to encoder: Swift.Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(try serializedData())
    }

    public var debugDescription: String {
        return "\(proto)"
    }
}

extension StorageServiceProtoCallLinkRecord {
    public static func builder() -> StorageServiceProtoCallLinkRecordBuilder {
        return StorageServiceProtoCallLinkRecordBuilder()
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> StorageServiceProtoCallLinkRecordBuilder {
        var builder = StorageServiceProtoCallLinkRecordBuilder()
        if let _value = rootKey {
            builder.setRootKey(_value)
        }
        if let _value = adminPasskey {
            builder.setAdminPasskey(_value)
        }
        builder.setDeletedAtTimestampMs(deletedAtTimestampMs)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct StorageServiceProtoCallLinkRecordBuilder {

    private var proto = StorageServiceProtos_CallLinkRecord()

    fileprivate init() {}

    @available(swift, obsoleted: 1.0)
    public mutating func setRootKey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.rootKey = valueParam
    }

    public mutating func setRootKey(_ valueParam: Data) {
        proto.rootKey = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setAdminPasskey(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.adminPasskey = valueParam
    }

    public mutating func setAdminPasskey(_ valueParam: Data) {
        proto.adminPasskey = valueParam
    }

    public mutating func setDeletedAtTimestampMs(_ valueParam: UInt64) {
        proto.deletedAtTimestampMs = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> StorageServiceProtoCallLinkRecord {
        return StorageServiceProtoCallLinkRecord(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try StorageServiceProtoCallLinkRecord(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension StorageServiceProtoCallLinkRecord {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension StorageServiceProtoCallLinkRecordBuilder {
    public func buildIgnoringErrors() -> StorageServiceProtoCallLinkRecord? {
        return self.buildInfallibly()
    }
}

#endif
