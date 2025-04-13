//
// Copyright 2020 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import GRDB

public class GRDBGroupsV2MessageJobFinder {
    typealias ReadTransaction = DBReadTransaction
    typealias WriteTransaction = DBWriteTransaction

    public func addJob(envelopeData: Data,
                       plaintextData: Data,
                       groupId: Data,
                       wasReceivedByUD: Bool,
                       serverDeliveryTimestamp: UInt64,
                       transaction: DBWriteTransaction) {
        let job = IncomingGroupsV2MessageJob(envelopeData: envelopeData,
                                             plaintextData: plaintextData,
                                             groupId: groupId,
                                             wasReceivedByUD: wasReceivedByUD,
                                             serverDeliveryTimestamp: serverDeliveryTimestamp)
        job.anyInsert(transaction: transaction)
    }

    public func allEnqueuedGroupIds(transaction: DBReadTransaction) -> [Data] {
        let sql = """
            SELECT DISTINCT \(incomingGroupsV2MessageJobColumn: .groupId)
            FROM \(IncomingGroupsV2MessageJobRecord.databaseTableName)
        """
        var result = [Data]()
        do {
            result = try Data.fetchAll(transaction.database, sql: sql)
        } catch {
            owsFailDebug("error: \(error)")
        }
        return result
    }

    public func nextJobs(batchSize: UInt, transaction: DBReadTransaction) -> [IncomingGroupsV2MessageJob] {
        let sql = """
            SELECT *
            FROM \(IncomingGroupsV2MessageJobRecord.databaseTableName)
            ORDER BY \(incomingGroupsV2MessageJobColumn: .id)
            LIMIT \(batchSize)
        """
        let cursor = IncomingGroupsV2MessageJob.grdbFetchCursor(sql: sql,
                                                                transaction: transaction)

        return try! cursor.all()
    }

    public func nextJobs(forGroupId groupId: Data,
                         batchSize: UInt,
                         transaction: DBReadTransaction) -> [IncomingGroupsV2MessageJob] {
        let sql = """
            SELECT *
            FROM \(IncomingGroupsV2MessageJobRecord.databaseTableName)
            WHERE \(incomingGroupsV2MessageJobColumn: .groupId) = ?
            ORDER BY \(incomingGroupsV2MessageJobColumn: .id)
            LIMIT \(batchSize)
        """
        let cursor = IncomingGroupsV2MessageJob.grdbFetchCursor(sql: sql,
                                                                arguments: [groupId],
                                                                transaction: transaction)

        return try! cursor.all()
    }

    public func existsJob(forGroupId groupId: Data, transaction: DBReadTransaction) -> Bool {
        let sql = """
            SELECT EXISTS (
                SELECT 1 FROM \(IncomingGroupsV2MessageJobRecord.databaseTableName)
                WHERE \(incomingGroupsV2MessageJobColumn: .groupId) = ?
            )
        """
        do {
            return try Bool.fetchOne(transaction.database, sql: sql, arguments: [groupId]) ?? false
        } catch {
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(
                userDefaults: CurrentAppContext().appUserDefaults(),
                error: error
            )
            owsFail("Failed to check job")
        }
    }

    public func jobCount(forGroupId groupId: Data, transaction: DBReadTransaction) -> UInt {
        let sql = """
            SELECT COUNT(*)
            FROM \(IncomingGroupsV2MessageJobRecord.databaseTableName)
            WHERE \(incomingGroupsV2MessageJobColumn: .groupId) = ?
        """
        do {
            return try UInt.fetchOne(transaction.database, sql: sql, arguments: [groupId]) ?? 0
        } catch {
            DatabaseCorruptionState.flagDatabaseReadCorruptionIfNecessary(
                userDefaults: CurrentAppContext().appUserDefaults(),
                error: error
            )
            owsFail("Failed to get job count")
        }
    }

    public func removeJobs(withUniqueIds uniqueIds: [String], transaction: DBWriteTransaction) {
        guard uniqueIds.count > 0 else {
            return
        }

        let commaSeparatedIds = uniqueIds.map { "\"\($0)\"" }.joined(separator: ", ")
        let sql = """
            DELETE
            FROM \(IncomingGroupsV2MessageJobRecord.databaseTableName)
            WHERE \(incomingGroupsV2MessageJobColumn: .uniqueId) in (\(commaSeparatedIds))
        """
        transaction.database.executeHandlingErrors(sql: sql)
    }

    public func jobCount(transaction: DBReadTransaction) -> UInt {
        return IncomingGroupsV2MessageJob.anyCount(transaction: transaction)
    }
}
