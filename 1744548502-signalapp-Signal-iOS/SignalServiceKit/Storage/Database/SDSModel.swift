//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import GRDB

public protocol SDSModel: TSYapDatabaseObject, SDSIdentifiableModel {
    var sdsTableName: String { get }

    func asRecord() -> SDSRecord

    var serializer: SDSSerializer { get }

    func anyInsert(transaction: DBWriteTransaction)

    static var table: SDSTableMetadata { get }
}

// MARK: -

public extension SDSModel {
    func sdsSave(saveMode: SDSSaveMode, transaction tx: DBWriteTransaction) {
        guard shouldBeSaved else {
            Logger.warn("Skipping save of: \(type(of: self))")
            return
        }

        switch saveMode {
        case .insert:
            anyWillInsert(with: tx)
        case .update:
            anyWillUpdate(with: tx)
        }

        let record = asRecord()
        record.sdsSave(saveMode: saveMode, transaction: tx)

        switch saveMode {
        case .insert:
            anyDidInsert(with: tx)
        case .update:
            anyDidUpdate(with: tx)
        }
    }

    func sdsRemove(transaction tx: DBWriteTransaction) {
        guard shouldBeSaved else {
            // Skipping remove.
            return
        }

        anyWillRemove(with: tx)

        // Don't use a record to delete the record;
        // asRecord() is expensive.
        let sql = """
            DELETE
            FROM \(sdsTableName)
            WHERE uniqueId == ?
        """
        tx.database.executeAndCacheStatementHandlingErrors(sql: sql, arguments: [uniqueId])

        anyDidRemove(with: tx)
    }
}

// MARK: -

public extension TableRecord {
    static func ows_fetchCount(_ db: Database) -> UInt {
        do {
            let result = try fetchCount(db)
            guard result >= 0 else {
                owsFailDebug("Invalid result: \(result)")
                return 0
            }
            guard result <= UInt.max else {
                owsFailDebug("Invalid result: \(result)")
                return UInt.max
            }
            return UInt(result)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return 0
        }
    }
}

// MARK: -

public extension SDSModel {
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    static func grdbEnumerateUniqueIds(
        transaction: DBReadTransaction,
        sql: String,
        batchSize: UInt,
        block: (String, UnsafeMutablePointer<ObjCBool>) -> Void
    ) {
        do {
            let cursor = try String.fetchCursor(transaction.database, sql: sql)
            try Batching.loop(batchSize: batchSize, loopBlock: { stop in
                guard let uniqueId = try cursor.next() else {
                    stop.pointee = true
                    return
                }
                block(uniqueId, stop)
            })
        } catch let error {
            owsFailDebug("Couldn't fetch uniqueIds: \(error)")
        }
    }
}

// MARK: - Cursors

public protocol SDSCursor {
    associatedtype Model: SDSModel
    mutating func next() throws -> Model?
}

public struct SDSMappedCursor<Cursor: SDSCursor, Element> {
    fileprivate var cursor: Cursor
    fileprivate let transform: (Cursor.Model) throws -> Element?

    public mutating func next() throws -> Element? {
        while let next = try cursor.next() {
            if let transformed = try transform(next) {
                return transformed
            }
        }
        return nil
    }
}

public extension SDSCursor {
    func map<Element>(transform: @escaping (Model) throws -> Element) -> SDSMappedCursor<Self, Element> {
        return compactMap(transform: transform)
    }

    func compactMap<Element>(transform: @escaping (Model) throws -> Element?) -> SDSMappedCursor<Self, Element> {
        return SDSMappedCursor(cursor: self, transform: transform)
    }
}
