//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient
import XCTest

@testable import SignalServiceKit

final class ThreadMergerTest: XCTestCase {
    private var callRecordStore: MockCallRecordStore!
    private var chatColorSettingStore: ChatColorSettingStore!
    private var db: InMemoryDB!
    private var deletedCallRecordStore: MockDeletedCallRecordStore!
    private var disappearingMessagesConfigurationManager: ThreadMerger_MockDisappearingMessagesConfigurationManager!
    private var disappearingMessagesConfigurationStore: MockDisappearingMessagesConfigurationStore!
    private var interactionStore: MockInteractionStore!
    private var pinnedThreadManager: MockPinnedThreadManager!
    private var threadAssociatedDataManager: ThreadMerger_MockThreadAssociatedDataManager!
    private var threadAssociatedDataStore: MockThreadAssociatedDataStore!
    private var threadStore: MockThreadStore!
    private var threadRemover: ThreadRemover!
    private var threadReplyInfoStore: ThreadReplyInfoStore!
    private var threadMerger: ThreadMerger!
    private var wallpaperStore: WallpaperStore!

    private var _signalServiceAddressCache: SignalServiceAddressCache!

    private let aci = Aci.constantForTesting("00000000-0000-4000-8000-000000000000")
    private let phoneNumber = E164("+16505550100")!

    private var serviceIdThread: TSContactThread!
    private var phoneNumberThread: TSContactThread!

    override func setUp() {

        _signalServiceAddressCache = SignalServiceAddressCache()

        callRecordStore = MockCallRecordStore()
        db = InMemoryDB()
        deletedCallRecordStore = MockDeletedCallRecordStore()
        disappearingMessagesConfigurationStore = MockDisappearingMessagesConfigurationStore()
        disappearingMessagesConfigurationManager = ThreadMerger_MockDisappearingMessagesConfigurationManager(disappearingMessagesConfigurationStore)
        pinnedThreadManager = MockPinnedThreadManager()
        interactionStore = MockInteractionStore()
        threadAssociatedDataStore = MockThreadAssociatedDataStore()
        threadAssociatedDataManager = ThreadMerger_MockThreadAssociatedDataManager(threadAssociatedDataStore)
        threadReplyInfoStore = ThreadReplyInfoStore()
        threadStore = MockThreadStore()
        wallpaperStore = WallpaperStore(
            wallpaperImageStore: MockWallpaperImageStore()
        )
        chatColorSettingStore = ChatColorSettingStore(
            wallpaperStore: wallpaperStore
        )
        threadRemover = ThreadRemoverImpl(
            chatColorSettingStore: chatColorSettingStore,
            databaseStorage: ThreadRemover_MockDatabaseStorage(),
            disappearingMessagesConfigurationStore: disappearingMessagesConfigurationStore,
            lastVisibleInteractionStore: LastVisibleInteractionStore(),
            threadAssociatedDataStore: threadAssociatedDataStore,
            threadReadCache: ThreadRemover_MockThreadReadCache(),
            threadReplyInfoStore: threadReplyInfoStore,
            threadSoftDeleteManager: MockThreadSoftDeleteManager(),
            threadStore: threadStore,
            wallpaperStore: wallpaperStore
        )
        threadMerger = ThreadMerger(
            callRecordStore: callRecordStore,
            chatColorSettingStore: chatColorSettingStore,
            deletedCallRecordStore: deletedCallRecordStore,
            disappearingMessagesConfigurationManager: disappearingMessagesConfigurationManager,
            disappearingMessagesConfigurationStore: disappearingMessagesConfigurationStore,
            interactionStore: interactionStore,
            pinnedThreadManager: pinnedThreadManager,
            sdsThreadMerger: ThreadMerger_MockSDSThreadMerger(),
            threadAssociatedDataManager: threadAssociatedDataManager,
            threadAssociatedDataStore: threadAssociatedDataStore,
            threadRemover: threadRemover,
            threadReplyInfoStore: threadReplyInfoStore,
            threadStore: threadStore,
            wallpaperImageStore: MockWallpaperImageStore(),
            wallpaperStore: wallpaperStore
        )

        serviceIdThread = makeThread(aci: aci, phoneNumber: nil)
        phoneNumberThread = makeThread(aci: nil, phoneNumber: phoneNumber)
    }

    // MARK: - Call Records

    func testCallRecordsThreadRowIds() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        performDefaultMerge()

        XCTAssertEqual(callRecordStore.askedToMergeThread!.from, phoneNumberThread.sqliteRowId!)
        XCTAssertEqual(callRecordStore.askedToMergeThread!.into, serviceIdThread.sqliteRowId!)

        XCTAssertEqual(deletedCallRecordStore.askedToMergeThread!.from, phoneNumberThread.sqliteRowId!)
        XCTAssertEqual(deletedCallRecordStore.askedToMergeThread!.into, serviceIdThread.sqliteRowId!)
    }

    // MARK: - Pinned Threads

    func testPinnedThreadsNeither() {
        let otherPinnedThreadId = "00000000-0000-4000-8000-000000000ABC"
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        pinnedThreadManager.pinnedThreadIds = [otherPinnedThreadId]
        performDefaultMerge()
        XCTAssertEqual(pinnedThreadManager.pinnedThreadIds, [otherPinnedThreadId])
    }

    func testPinnedThreadsJustServiceId() {
        let otherPinnedThreadId = "00000000-0000-4000-8000-000000000ABC"
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        pinnedThreadManager.pinnedThreadIds = [otherPinnedThreadId, serviceIdThread.uniqueId]
        performDefaultMerge()
        XCTAssertEqual(pinnedThreadManager.pinnedThreadIds, [otherPinnedThreadId, serviceIdThread.uniqueId])
    }

    func testPinnedThreadsJustPhoneNumber() {
        let otherPinnedThreadId = "00000000-0000-4000-8000-000000000ABC"
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        pinnedThreadManager.pinnedThreadIds = [phoneNumberThread.uniqueId, otherPinnedThreadId]
        performDefaultMerge()
        XCTAssertEqual(pinnedThreadManager.pinnedThreadIds, [serviceIdThread.uniqueId, otherPinnedThreadId])
    }

    func testPinnedThreadsBoth() {
        let otherPinnedThreadId = "00000000-0000-4000-8000-000000000ABC"
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        pinnedThreadManager.pinnedThreadIds = [phoneNumberThread.uniqueId, serviceIdThread.uniqueId, otherPinnedThreadId]
        performDefaultMerge()
        XCTAssertEqual(pinnedThreadManager.pinnedThreadIds, [serviceIdThread.uniqueId, otherPinnedThreadId])
    }

    // MARK: - Disappearing Messages

    private func setDisappearingMessageIntervals(serviceIdValue: UInt32?, phoneNumberValue: UInt32?) {
        disappearingMessagesConfigurationStore.values = [
            serviceIdThread.uniqueId: OWSDisappearingMessagesConfiguration(
                threadId: serviceIdThread.uniqueId,
                enabled: serviceIdValue != nil,
                durationSeconds: serviceIdValue ?? 0,
                timerVersion: 1
            ),
            phoneNumberThread.uniqueId: OWSDisappearingMessagesConfiguration(
                threadId: phoneNumberThread.uniqueId,
                enabled: phoneNumberValue != nil,
                durationSeconds: phoneNumberValue ?? 0,
                timerVersion: 1
            )
        ]
    }

    private func getDisappearingMessageIntervals() -> [String: UInt32?] {
        disappearingMessagesConfigurationStore.values.mapValues { $0.isEnabled ? $0.durationSeconds : nil }
    }

    func testDisappearingMessagesNeither() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setDisappearingMessageIntervals(serviceIdValue: nil, phoneNumberValue: nil)
        performDefaultMerge()
        XCTAssertEqual(getDisappearingMessageIntervals(), [serviceIdThread.uniqueId: nil])
    }

    func testDisappearingMessagesJustServiceId() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setDisappearingMessageIntervals(serviceIdValue: 5, phoneNumberValue: nil)
        performDefaultMerge()
        XCTAssertEqual(getDisappearingMessageIntervals(), [serviceIdThread.uniqueId: 5])
    }

    func testDisappearingMessagesJustPhoneNumber() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setDisappearingMessageIntervals(serviceIdValue: nil, phoneNumberValue: 5)
        performDefaultMerge()
        XCTAssertEqual(getDisappearingMessageIntervals(), [serviceIdThread.uniqueId: 5])
    }

    func testDisappearingMessagesBothShorterPhoneNumber() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setDisappearingMessageIntervals(serviceIdValue: 5, phoneNumberValue: 3)
        performDefaultMerge()
        XCTAssertEqual(getDisappearingMessageIntervals(), [serviceIdThread.uniqueId: 3])
    }

    func testDisappearingMessagesBothShorterServiceId() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setDisappearingMessageIntervals(serviceIdValue: 2, phoneNumberValue: 3)
        performDefaultMerge()
        XCTAssertEqual(getDisappearingMessageIntervals(), [serviceIdThread.uniqueId: 2])
    }

    // MARK: - Thread Associated Data

    private func setThreadAssociatedData(for thread: TSContactThread, isArchived: Bool, isMarkedUnread: Bool, mutedUntilTimestamp: UInt64, audioPlaybackRate: Float) {
        threadAssociatedDataStore.values[thread.uniqueId] = ThreadAssociatedData(
            threadUniqueId: thread.uniqueId,
            isArchived: isArchived,
            isMarkedUnread: isMarkedUnread,
            mutedUntilTimestamp: mutedUntilTimestamp,
            audioPlaybackRate: audioPlaybackRate
        )
    }

    private func getThreadAssociatedDatas() -> [String: String] {
        threadAssociatedDataStore.values.mapValues {
            "\($0.isArchived)-\($0.isMarkedUnread)-\($0.mutedUntilTimestamp)-\($0.audioPlaybackRate)"
        }
    }

    func testThreadAssociatedDataNeither() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        performDefaultMerge()
        XCTAssertEqual(getThreadAssociatedDatas(), [serviceIdThread.uniqueId: "false-false-0-1.0"])
    }

    func testThreadAssociatedDataJustServiceId() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setThreadAssociatedData(for: serviceIdThread, isArchived: true, isMarkedUnread: false, mutedUntilTimestamp: 1, audioPlaybackRate: 2)
        performDefaultMerge()
        XCTAssertEqual(getThreadAssociatedDatas(), [serviceIdThread.uniqueId: "false-false-1-2.0"])
    }

    func testThreadAssociatedDataJustPhoneNumber() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setThreadAssociatedData(for: phoneNumberThread, isArchived: false, isMarkedUnread: true, mutedUntilTimestamp: 2, audioPlaybackRate: 3)
        performDefaultMerge()
        XCTAssertEqual(getThreadAssociatedDatas(), [serviceIdThread.uniqueId: "false-true-2-3.0"])
    }

    func testThreadAssociatedDataBoth() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        setThreadAssociatedData(for: serviceIdThread, isArchived: true, isMarkedUnread: false, mutedUntilTimestamp: 4, audioPlaybackRate: 1)
        setThreadAssociatedData(for: phoneNumberThread, isArchived: true, isMarkedUnread: false, mutedUntilTimestamp: 5, audioPlaybackRate: 0.5)
        performDefaultMerge()
        XCTAssertEqual(getThreadAssociatedDatas(), [serviceIdThread.uniqueId: "true-false-5-0.5"])
    }

    // MARK: - Thread Reply Info

    func testThreadReplyInfoNeither() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        performDefaultMerge()
        db.read { tx in
            XCTAssertNil(threadReplyInfoStore.fetch(for: serviceIdThread.uniqueId, tx: tx))
            XCTAssertNil(threadReplyInfoStore.fetch(for: phoneNumberThread.uniqueId, tx: tx))
        }
    }

    func testThreadReplyInfoJustPhoneNumber() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        db.write { tx in
            threadReplyInfoStore.save(ThreadReplyInfo(timestamp: 2, author: aci), for: phoneNumberThread.uniqueId, tx: tx)
        }
        performDefaultMerge()
        db.read { tx in
            XCTAssertEqual(threadReplyInfoStore.fetch(for: serviceIdThread.uniqueId, tx: tx)?.timestamp, 2)
            XCTAssertNil(threadReplyInfoStore.fetch(for: phoneNumberThread.uniqueId, tx: tx))
        }
    }

    func testThreadReplyInfoBoth() {
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        db.write { tx in
            threadReplyInfoStore.save(ThreadReplyInfo(timestamp: 3, author: aci), for: serviceIdThread.uniqueId, tx: tx)
            threadReplyInfoStore.save(ThreadReplyInfo(timestamp: 4, author: aci), for: phoneNumberThread.uniqueId, tx: tx)
        }
        performDefaultMerge()
        db.read { tx in
            XCTAssertEqual(threadReplyInfoStore.fetch(for: serviceIdThread.uniqueId, tx: tx)?.timestamp, 3)
            XCTAssertNil(threadReplyInfoStore.fetch(for: phoneNumberThread.uniqueId, tx: tx))
        }
    }

    // MARK: - Thread Merge Events

    func testThreadMergeEvent() throws {
        serviceIdThread.shouldThreadBeVisible = true
        phoneNumberThread.shouldThreadBeVisible = true
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        performDefaultMerge()
        let threadMergeEvent = try XCTUnwrap(interactionStore.insertedInteractions.first as? TSInfoMessage)
        XCTAssertEqual(interactionStore.insertedInteractions.count, 1)
        XCTAssertEqual(threadMergeEvent.messageType, .threadMerge)
        XCTAssertEqual(threadMergeEvent.threadMergePhoneNumber, phoneNumber.stringValue)
    }

    func testThreadMergeEventInvisibleThread() {
        serviceIdThread.shouldThreadBeVisible = true
        phoneNumberThread.shouldThreadBeVisible = false
        threadStore.insertThreads([serviceIdThread, phoneNumberThread])
        performDefaultMerge()
        XCTAssertEqual(interactionStore.insertedInteractions.count, 0)
    }

    func testThreadMergeEventTwoAcis() throws {
        let thread1 = makeThread(aci: aci, phoneNumber: nil)
        thread1.shouldThreadBeVisible = true
        let thread2 = makeThread(aci: aci, phoneNumber: nil)
        thread2.shouldThreadBeVisible = true
        threadStore.insertThreads([thread1, thread2])
        performDefaultMerge()
        let threadMergeEvent = try XCTUnwrap(interactionStore.insertedInteractions.first as? TSInfoMessage)
        XCTAssertEqual(interactionStore.insertedInteractions.count, 1)
        XCTAssertEqual(threadMergeEvent.messageType, .threadMerge)
        XCTAssertNil(threadMergeEvent.threadMergePhoneNumber)
    }

    // MARK: - Raw SDS Migrations

    // MARK: - Helpers

    private func performDefaultMerge() {
        db.write { tx in
            _ = threadMerger.didLearnAssociation(
                mergedRecipient: MergedRecipient(
                    isLocalRecipient: false,
                    oldRecipient: nil,
                    newRecipient: SignalRecipient(aci: aci, pni: nil, phoneNumber: phoneNumber)
                ),
                tx: tx
            )
        }
    }

    private func makeThread(aci: Aci?, phoneNumber: E164?) -> TSContactThread {
        let result = TSContactThread(contactAddress: SignalServiceAddress(
            serviceId: aci,
            phoneNumber: phoneNumber?.stringValue,
            cache: _signalServiceAddressCache
        ))
        threadAssociatedDataStore.values[result.uniqueId] = ThreadAssociatedData(threadUniqueId: result.uniqueId)
        return result
    }
}
