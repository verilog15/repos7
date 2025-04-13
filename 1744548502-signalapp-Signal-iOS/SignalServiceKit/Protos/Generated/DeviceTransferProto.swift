//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import SwiftProtobuf

// WARNING: This code is generated. Only edit within the markers.

public enum DeviceTransferProtoError: Error {
    case invalidProtobuf(description: String)
}

// MARK: - DeviceTransferProtoFile

public struct DeviceTransferProtoFile: Codable, CustomDebugStringConvertible {

    fileprivate let proto: DeviceTransferProtos_File

    public let identifier: String

    public let relativePath: String

    public let estimatedSize: UInt64

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: DeviceTransferProtos_File,
                 identifier: String,
                 relativePath: String,
                 estimatedSize: UInt64) {
        self.proto = proto
        self.identifier = identifier
        self.relativePath = relativePath
        self.estimatedSize = estimatedSize
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try DeviceTransferProtos_File(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: DeviceTransferProtos_File) {
        let identifier = proto.identifier

        let relativePath = proto.relativePath

        let estimatedSize = proto.estimatedSize

        self.init(proto: proto,
                  identifier: identifier,
                  relativePath: relativePath,
                  estimatedSize: estimatedSize)
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

extension DeviceTransferProtoFile {
    public static func builder(identifier: String, relativePath: String, estimatedSize: UInt64) -> DeviceTransferProtoFileBuilder {
        return DeviceTransferProtoFileBuilder(identifier: identifier, relativePath: relativePath, estimatedSize: estimatedSize)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> DeviceTransferProtoFileBuilder {
        var builder = DeviceTransferProtoFileBuilder(identifier: identifier, relativePath: relativePath, estimatedSize: estimatedSize)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct DeviceTransferProtoFileBuilder {

    private var proto = DeviceTransferProtos_File()

    fileprivate init() {}

    fileprivate init(identifier: String, relativePath: String, estimatedSize: UInt64) {

        setIdentifier(identifier)
        setRelativePath(relativePath)
        setEstimatedSize(estimatedSize)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setIdentifier(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.identifier = valueParam
    }

    public mutating func setIdentifier(_ valueParam: String) {
        proto.identifier = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setRelativePath(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.relativePath = valueParam
    }

    public mutating func setRelativePath(_ valueParam: String) {
        proto.relativePath = valueParam
    }

    public mutating func setEstimatedSize(_ valueParam: UInt64) {
        proto.estimatedSize = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> DeviceTransferProtoFile {
        return DeviceTransferProtoFile(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try DeviceTransferProtoFile(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension DeviceTransferProtoFile {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension DeviceTransferProtoFileBuilder {
    public func buildIgnoringErrors() -> DeviceTransferProtoFile? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - DeviceTransferProtoDefault

public struct DeviceTransferProtoDefault: Codable, CustomDebugStringConvertible {

    fileprivate let proto: DeviceTransferProtos_Default

    public let key: String

    public let encodedValue: Data

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: DeviceTransferProtos_Default,
                 key: String,
                 encodedValue: Data) {
        self.proto = proto
        self.key = key
        self.encodedValue = encodedValue
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try DeviceTransferProtos_Default(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: DeviceTransferProtos_Default) {
        let key = proto.key

        let encodedValue = proto.encodedValue

        self.init(proto: proto,
                  key: key,
                  encodedValue: encodedValue)
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

extension DeviceTransferProtoDefault {
    public static func builder(key: String, encodedValue: Data) -> DeviceTransferProtoDefaultBuilder {
        return DeviceTransferProtoDefaultBuilder(key: key, encodedValue: encodedValue)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> DeviceTransferProtoDefaultBuilder {
        var builder = DeviceTransferProtoDefaultBuilder(key: key, encodedValue: encodedValue)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct DeviceTransferProtoDefaultBuilder {

    private var proto = DeviceTransferProtos_Default()

    fileprivate init() {}

    fileprivate init(key: String, encodedValue: Data) {

        setKey(key)
        setEncodedValue(encodedValue)
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setKey(_ valueParam: String?) {
        guard let valueParam = valueParam else { return }
        proto.key = valueParam
    }

    public mutating func setKey(_ valueParam: String) {
        proto.key = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setEncodedValue(_ valueParam: Data?) {
        guard let valueParam = valueParam else { return }
        proto.encodedValue = valueParam
    }

    public mutating func setEncodedValue(_ valueParam: Data) {
        proto.encodedValue = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> DeviceTransferProtoDefault {
        return DeviceTransferProtoDefault(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try DeviceTransferProtoDefault(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension DeviceTransferProtoDefault {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension DeviceTransferProtoDefaultBuilder {
    public func buildIgnoringErrors() -> DeviceTransferProtoDefault? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - DeviceTransferProtoDatabase

public struct DeviceTransferProtoDatabase: Codable, CustomDebugStringConvertible {

    fileprivate let proto: DeviceTransferProtos_Database

    public let key: Data

    public let database: DeviceTransferProtoFile

    public let wal: DeviceTransferProtoFile

    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: DeviceTransferProtos_Database,
                 key: Data,
                 database: DeviceTransferProtoFile,
                 wal: DeviceTransferProtoFile) {
        self.proto = proto
        self.key = key
        self.database = database
        self.wal = wal
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try DeviceTransferProtos_Database(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: DeviceTransferProtos_Database) {
        let key = proto.key

        let database = DeviceTransferProtoFile(proto.database)

        let wal = DeviceTransferProtoFile(proto.wal)

        self.init(proto: proto,
                  key: key,
                  database: database,
                  wal: wal)
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

extension DeviceTransferProtoDatabase {
    public static func builder(key: Data, database: DeviceTransferProtoFile, wal: DeviceTransferProtoFile) -> DeviceTransferProtoDatabaseBuilder {
        return DeviceTransferProtoDatabaseBuilder(key: key, database: database, wal: wal)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> DeviceTransferProtoDatabaseBuilder {
        var builder = DeviceTransferProtoDatabaseBuilder(key: key, database: database, wal: wal)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct DeviceTransferProtoDatabaseBuilder {

    private var proto = DeviceTransferProtos_Database()

    fileprivate init() {}

    fileprivate init(key: Data, database: DeviceTransferProtoFile, wal: DeviceTransferProtoFile) {

        setKey(key)
        setDatabase(database)
        setWal(wal)
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
    public mutating func setDatabase(_ valueParam: DeviceTransferProtoFile?) {
        guard let valueParam = valueParam else { return }
        proto.database = valueParam.proto
    }

    public mutating func setDatabase(_ valueParam: DeviceTransferProtoFile) {
        proto.database = valueParam.proto
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setWal(_ valueParam: DeviceTransferProtoFile?) {
        guard let valueParam = valueParam else { return }
        proto.wal = valueParam.proto
    }

    public mutating func setWal(_ valueParam: DeviceTransferProtoFile) {
        proto.wal = valueParam.proto
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> DeviceTransferProtoDatabase {
        return DeviceTransferProtoDatabase(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try DeviceTransferProtoDatabase(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension DeviceTransferProtoDatabase {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension DeviceTransferProtoDatabaseBuilder {
    public func buildIgnoringErrors() -> DeviceTransferProtoDatabase? {
        return self.buildInfallibly()
    }
}

#endif

// MARK: - DeviceTransferProtoManifest

public struct DeviceTransferProtoManifest: Codable, CustomDebugStringConvertible {

    fileprivate let proto: DeviceTransferProtos_Manifest

    public let grdbSchemaVersion: UInt64

    public let database: DeviceTransferProtoDatabase?

    public let appDefaults: [DeviceTransferProtoDefault]

    public let standardDefaults: [DeviceTransferProtoDefault]

    public let files: [DeviceTransferProtoFile]

    public var estimatedTotalSize: UInt64 {
        return proto.estimatedTotalSize
    }
    public var hasUnknownFields: Bool {
        return !proto.unknownFields.data.isEmpty
    }
    public var unknownFields: SwiftProtobuf.UnknownStorage? {
        guard hasUnknownFields else { return nil }
        return proto.unknownFields
    }

    private init(proto: DeviceTransferProtos_Manifest,
                 grdbSchemaVersion: UInt64,
                 database: DeviceTransferProtoDatabase?,
                 appDefaults: [DeviceTransferProtoDefault],
                 standardDefaults: [DeviceTransferProtoDefault],
                 files: [DeviceTransferProtoFile]) {
        self.proto = proto
        self.grdbSchemaVersion = grdbSchemaVersion
        self.database = database
        self.appDefaults = appDefaults
        self.standardDefaults = standardDefaults
        self.files = files
    }

    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    public init(serializedData: Data) throws {
        let proto = try DeviceTransferProtos_Manifest(serializedBytes: serializedData)
        self.init(proto)
    }

    fileprivate init(_ proto: DeviceTransferProtos_Manifest) {
        let grdbSchemaVersion = proto.grdbSchemaVersion

        var database: DeviceTransferProtoDatabase?
        if proto.hasDatabase {
            database = DeviceTransferProtoDatabase(proto.database)
        }

        var appDefaults: [DeviceTransferProtoDefault] = []
        appDefaults = proto.appDefaults.map { DeviceTransferProtoDefault($0) }

        var standardDefaults: [DeviceTransferProtoDefault] = []
        standardDefaults = proto.standardDefaults.map { DeviceTransferProtoDefault($0) }

        var files: [DeviceTransferProtoFile] = []
        files = proto.files.map { DeviceTransferProtoFile($0) }

        self.init(proto: proto,
                  grdbSchemaVersion: grdbSchemaVersion,
                  database: database,
                  appDefaults: appDefaults,
                  standardDefaults: standardDefaults,
                  files: files)
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

extension DeviceTransferProtoManifest {
    public static func builder(grdbSchemaVersion: UInt64) -> DeviceTransferProtoManifestBuilder {
        return DeviceTransferProtoManifestBuilder(grdbSchemaVersion: grdbSchemaVersion)
    }

    // asBuilder() constructs a builder that reflects the proto's contents.
    public func asBuilder() -> DeviceTransferProtoManifestBuilder {
        var builder = DeviceTransferProtoManifestBuilder(grdbSchemaVersion: grdbSchemaVersion)
        if let _value = database {
            builder.setDatabase(_value)
        }
        builder.setAppDefaults(appDefaults)
        builder.setStandardDefaults(standardDefaults)
        builder.setFiles(files)
        builder.setEstimatedTotalSize(estimatedTotalSize)
        if let _value = unknownFields {
            builder.setUnknownFields(_value)
        }
        return builder
    }
}

public struct DeviceTransferProtoManifestBuilder {

    private var proto = DeviceTransferProtos_Manifest()

    fileprivate init() {}

    fileprivate init(grdbSchemaVersion: UInt64) {

        setGrdbSchemaVersion(grdbSchemaVersion)
    }

    public mutating func setGrdbSchemaVersion(_ valueParam: UInt64) {
        proto.grdbSchemaVersion = valueParam
    }

    @available(swift, obsoleted: 1.0)
    public mutating func setDatabase(_ valueParam: DeviceTransferProtoDatabase?) {
        guard let valueParam = valueParam else { return }
        proto.database = valueParam.proto
    }

    public mutating func setDatabase(_ valueParam: DeviceTransferProtoDatabase) {
        proto.database = valueParam.proto
    }

    public mutating func addAppDefaults(_ valueParam: DeviceTransferProtoDefault) {
        proto.appDefaults.append(valueParam.proto)
    }

    public mutating func setAppDefaults(_ wrappedItems: [DeviceTransferProtoDefault]) {
        proto.appDefaults = wrappedItems.map { $0.proto }
    }

    public mutating func addStandardDefaults(_ valueParam: DeviceTransferProtoDefault) {
        proto.standardDefaults.append(valueParam.proto)
    }

    public mutating func setStandardDefaults(_ wrappedItems: [DeviceTransferProtoDefault]) {
        proto.standardDefaults = wrappedItems.map { $0.proto }
    }

    public mutating func addFiles(_ valueParam: DeviceTransferProtoFile) {
        proto.files.append(valueParam.proto)
    }

    public mutating func setFiles(_ wrappedItems: [DeviceTransferProtoFile]) {
        proto.files = wrappedItems.map { $0.proto }
    }

    public mutating func setEstimatedTotalSize(_ valueParam: UInt64) {
        proto.estimatedTotalSize = valueParam
    }

    public mutating func setUnknownFields(_ unknownFields: SwiftProtobuf.UnknownStorage) {
        proto.unknownFields = unknownFields
    }

    public func buildInfallibly() -> DeviceTransferProtoManifest {
        return DeviceTransferProtoManifest(proto)
    }

    public func buildSerializedData() throws -> Data {
        return try DeviceTransferProtoManifest(proto).serializedData()
    }
}

#if TESTABLE_BUILD

extension DeviceTransferProtoManifest {
    public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension DeviceTransferProtoManifestBuilder {
    public func buildIgnoringErrors() -> DeviceTransferProtoManifest? {
        return self.buildInfallibly()
    }
}

#endif
