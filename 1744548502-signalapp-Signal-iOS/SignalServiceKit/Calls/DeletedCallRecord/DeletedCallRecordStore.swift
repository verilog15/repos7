//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import GRDB

protocol DeletedCallRecordStore {
    /// Fetches a deleted call record with the given identifying properties, if
    /// one exists.
    func fetch(
        callId: UInt64,
        conversationId: CallRecord.ConversationID,
        tx: DBReadTransaction
    ) -> DeletedCallRecord?

    /// Insert the given deleted call record.
    func insert(deletedCallRecord: DeletedCallRecord, tx: DBWriteTransaction)

    /// Deletes the given deleted call record, which was created sufficiently
    /// long ago as to now be expired.
    func delete(
        expiredDeletedCallRecord: DeletedCallRecord,
        tx: DBWriteTransaction
    )

    /// Returns the oldest deleted call record; i.e., the deleted call record
    /// with the oldest `deletedAtTimestamp`.
    func nextDeletedRecord(tx: DBReadTransaction) -> DeletedCallRecord?

    /// Update all relevant records in response to a thread merge.
    /// - Parameter fromThreadRowId
    /// The SQLite row ID of the thread being merged from.
    /// - Parameter intoThreadRowId
    /// The SQLite row ID of the thread being merged into.
    func updateWithMergedThread(
        fromThreadRowId fromRowId: Int64,
        intoThreadRowId intoRowId: Int64,
        tx: DBWriteTransaction
    )
}

extension DeletedCallRecordStore {
    /// Whether the store contains a deleted call record with the given
    /// identifying properties.
    func contains(callId: UInt64, conversationId: CallRecord.ConversationID, tx: DBReadTransaction) -> Bool {
        return fetch(callId: callId, conversationId: conversationId, tx: tx) != nil
    }
}

// MARK: -

class DeletedCallRecordStoreImpl: DeletedCallRecordStore {
    fileprivate enum ColumnArg {
        case equal(
            column: DeletedCallRecord.CodingKeys,
            value: DatabaseValueConvertible
        )

        case ascending(column: DeletedCallRecord.CodingKeys)

        var column: DeletedCallRecord.CodingKeys {
            switch self {
            case .equal(let column, _):
                return column
            case .ascending(let column):
                return column
            }
        }
    }

    init() {}

    // MARK: -

    func fetch(
        callId: UInt64,
        conversationId: CallRecord.ConversationID,
        tx: DBReadTransaction
    ) -> DeletedCallRecord? {
        switch conversationId {
        case .thread(let threadRowId):
            return fetch(
                columnArgs: [
                    .equal(column: .callIdString, value: String(callId)),
                    .equal(column: .threadRowId, value: threadRowId)
                ],
                tx: tx
            )
        case .callLink(let callLinkRowId):
            return fetch(
                columnArgs: [
                    .equal(column: .callIdString, value: String(callId)),
                    .equal(column: .callLinkRowId, value: callLinkRowId)
                ],
                tx: tx
            )
        }
    }

    // MARK: -

    func insert(
        deletedCallRecord: DeletedCallRecord,
        tx: DBWriteTransaction
    ) {
        do {
            try deletedCallRecord.insert(tx.database)
        } catch let error {
            owsFailBeta("Failed to insert deleted call record: \(error)")
        }
    }

    // MARK: -

    func delete(expiredDeletedCallRecord: DeletedCallRecord, tx: DBWriteTransaction) {
        do {
            try expiredDeletedCallRecord.delete(tx.database)
        } catch let error {
            owsFailBeta("Failed to delete expired deleted call record: \(error)")
        }
    }

    // MARK: -

    func nextDeletedRecord(tx: DBReadTransaction) -> DeletedCallRecord? {
        return fetch(
            columnArgs: [.ascending(column: .deletedAtTimestamp)],
            tx: tx
        )
    }

    // MARK: -

    func updateWithMergedThread(
        fromThreadRowId fromRowId: Int64,
        intoThreadRowId intoRowId: Int64,
        tx: DBWriteTransaction
    ) {
        tx.database.executeHandlingErrors(
            sql: """
                UPDATE "\(DeletedCallRecord.databaseTableName)"
                SET "\(DeletedCallRecord.CodingKeys.threadRowId.rawValue)" = ?
                WHERE "\(DeletedCallRecord.CodingKeys.threadRowId.rawValue)" = ?
            """,
            arguments: [ intoRowId, fromRowId ]
        )
    }

    // MARK: -

    fileprivate func fetch(
        columnArgs: [ColumnArg],
        tx: DBReadTransaction
    ) -> DeletedCallRecord? {
        let (sqlString, sqlArgs) = compileQuery(columnArgs: columnArgs)

        do {
            return try DeletedCallRecord.fetchOne(tx.database, SQLRequest(
                sql: sqlString,
                arguments: StatementArguments(sqlArgs)
            ))
        } catch let error {
            let columns = columnArgs.map { $0.column }
            owsFailBeta("Error fetching CallRecord by \(columns): \(error)")
            return nil
        }
    }

    fileprivate func compileQuery(
        columnArgs: [ColumnArg]
    ) -> (sqlString: String, sqlArgs: [DatabaseValueConvertible]) {
        var equalityClauses = [String]()
        var equalityArgs = [DatabaseValueConvertible]()
        var orderingClause: String?

        for columnArg in columnArgs {
            switch columnArg {
            case .equal(let column, let value):
                equalityClauses.append("\(column.rawValue) = ?")
                equalityArgs.append(value)
            case .ascending(let column):
                owsPrecondition(
                    orderingClause == nil,
                    "Multiple ordering clauses! How did that happen?"
                )

                orderingClause = "ORDER BY \(column.rawValue) ASC"
            }
        }

        let whereClause: String = {
            if equalityClauses.isEmpty {
                return ""
            } else {
                return "WHERE \(equalityClauses.joined(separator: " AND "))"
            }
        }()

        return (
            sqlString: """
                SELECT * FROM \(DeletedCallRecord.databaseTableName)
                \(whereClause)
                \(orderingClause ?? "")
            """,
            sqlArgs: equalityArgs
        )
    }
}

// MARK: -

#if TESTABLE_BUILD

final class ExplainingDeletedCallRecordStoreImpl: DeletedCallRecordStoreImpl {
    var lastExplanation: String?

    override fileprivate func fetch(
        columnArgs: [ColumnArg],
        tx: DBReadTransaction
    ) -> DeletedCallRecord? {
        let (sqlString, sqlArgs) = compileQuery(columnArgs: columnArgs)

        guard
            let explanationRow = try? Row.fetchOne(tx.database, SQLRequest(
                sql: "EXPLAIN QUERY PLAN \(sqlString)",
                arguments: StatementArguments(sqlArgs)
            )),
            let explanation = explanationRow[3] as? String
        else {
            // This isn't likely to be stable indefinitely, but it appears for
            // now that the explanation is the fourth item in the row.
            owsFail("Failed to get explanation for query!")
        }

        lastExplanation = explanation

        return super.fetch(columnArgs: columnArgs, tx: tx)
    }
}

#endif
