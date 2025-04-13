//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import GRDB
import LibSignalClient
import SignalServiceKit
import XCTest

final class SpamReportingTokenRecordTest: XCTestCase {
    private func createDatabaseQueue() throws -> DatabaseQueue {
        let result = DatabaseQueue()

        try result.write { db in
            try db.create(table: SpamReportingTokenRecord.databaseTableName) { table in
                table.column("sourceUuid", .blob).primaryKey().notNull()
                table.column("spamReportingToken", .blob).notNull()
            }
        }

        return result
    }

    func testRoundTrip() throws {
        let sourceAci = Aci.randomForTesting()
        let spamReportingToken = SpamReportingToken(data: .init([1, 2, 3]))!

        let databaseQueue = try createDatabaseQueue()

        try databaseQueue.write { db in
            let record = SpamReportingTokenRecord(
                sourceAci: sourceAci,
                spamReportingToken: spamReportingToken
            )
            try record.insert(db)
        }

        let loadedRecord = try databaseQueue.read { db in
            try SpamReportingTokenRecord.fetchOne(db, key: sourceAci.rawUUID)!
        }
        XCTAssertEqual(loadedRecord.sourceAci, sourceAci)
        XCTAssertEqual(loadedRecord.spamReportingToken, spamReportingToken)
    }

    func testUpsert() throws {
        let sourceAci1 = Aci.randomForTesting()
        let sourceAci2 = Aci.randomForTesting()
        let spamReportingToken1 = SpamReportingToken(data: .init([1]))!
        let spamReportingToken2 = SpamReportingToken(data: .init([2]))!

        let databaseQueue = try createDatabaseQueue()

        try databaseQueue.write { db in
            let recordsToUpsert: [SpamReportingTokenRecord] = [
                .init(sourceAci: sourceAci1, spamReportingToken: spamReportingToken1),
                .init(sourceAci: sourceAci2, spamReportingToken: spamReportingToken1),
                .init(sourceAci: sourceAci1, spamReportingToken: spamReportingToken2)
            ]
            for record in recordsToUpsert {
                try record.upsert(db)
            }
        }

        let (tokenForUuid1, tokenForUuid2) = try databaseQueue.read { db in (
            try SpamReportingTokenRecord.fetchOne(db, key: sourceAci1.rawUUID)?.spamReportingToken,
            try SpamReportingTokenRecord.fetchOne(db, key: sourceAci2.rawUUID)?.spamReportingToken
        )}
        XCTAssertEqual(tokenForUuid1, spamReportingToken2)
        XCTAssertEqual(tokenForUuid2, spamReportingToken1)
    }
}
