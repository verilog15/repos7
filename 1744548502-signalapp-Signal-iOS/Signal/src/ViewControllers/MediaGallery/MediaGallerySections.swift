//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalServiceKit

struct MediaGalleryIndexPath: Comparable {
    var indexPath: IndexPath

    var item: Int {
        get { indexPath.item }
        set { indexPath.item = newValue }
    }
    var section: Int {
        get { indexPath.section }
        set { indexPath.section = newValue }
    }
    var count: Int { indexPath.count }

    init(item: Int, section: Int) {
        indexPath = IndexPath(item: item, section: section)
    }

    init(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }

    static func < (lhs: MediaGalleryIndexPath, rhs: MediaGalleryIndexPath) -> Bool {
        return lhs.indexPath < rhs.indexPath
    }
}

/// The minimal requirements needed for items loaded and managed by MediaGallerySections.
internal protocol MediaGallerySectionItem {
    var attachmentId: AttachmentReferenceId { get }
    var galleryDate: GalleryDate { get }
}

/// Represents a source of items ordered by timestamp and partitioned by gallery date.
internal protocol MediaGallerySectionLoader {
    associatedtype Item: MediaGallerySectionItem

    /// Should return the row IDs of items in the section represented by `date`.
    ///
    /// In practice this should be the items within the date's `interval`.
    func rowIdsAndDatesOfItemsInSection(
        for date: GalleryDate,
        offset: Int,
        ascending: Bool,
        transaction: DBReadTransaction
    ) -> [DatedAttachmentReferenceId]

    /// Should call `block` once for every item (loaded or unloaded) before `date`, up to `count` times.
    func enumerateTimestamps(
        before date: Date,
        count: Int,
        transaction: DBReadTransaction,
        block: (DatedAttachmentReferenceId) -> Void
    ) -> MediaGalleryAttachmentFinder.EnumerationCompletion

    /// Should call `block` once for every item (loaded or unloaded) after `date`, up to `count` times.
    func enumerateTimestamps(
        after date: Date,
        count: Int,
        transaction: DBReadTransaction,
        block: (DatedAttachmentReferenceId) -> Void
    ) -> MediaGalleryAttachmentFinder.EnumerationCompletion

    /// Should selects a range of items in `interval` and call `block` once for each.
    ///
    /// For example, if `interval` represents May 2022 and there are seven photos received during this interval,
    /// a `range` of `2..<5` should call `block` with the offsets 2, 3, and 4, in that order. `uniqueId` will be used
    /// to determine whether the item needs to be built fresh or whether an existing object can be used.
    func enumerateItems(
        in interval: DateInterval,
        range: Range<Int>,
        transaction: DBReadTransaction,
        block: (_ offset: Int, _ attachmentId: AttachmentReferenceId, _ buildItem: () -> Item) -> Void
    )
}

/// The underlying model for MediaGallery, itself the backing store for media views (page-based or tile-based)
///
/// MediaGallerySections models a list of GalleryDate-based sections, each of which has a certain number of items.
/// Sections are loaded on demand (that is, there may be newer and older sections that are not in the model), and always
/// know their number of items. Items are also loaded on demand, potentially non-contiguously.
///
/// This model is designed around the needs of UICollectionView, but it also supports flat views of media.
internal struct MediaGallerySections<Loader: MediaGallerySectionLoader, UpdateUserData> {
    internal typealias Item = Loader.Item

    struct MediaGallerySlot {
        /// This is a stable and unique identifier for an item.
        var itemId: AttachmentReferenceId
        /// This comes from `TSInteraction.receivedAtTimestamp`.
        var receivedAt: Date
        var item: Item?
    }

    struct State {
        /// All sections we know about.
        ///
        /// Each section contains an array of possibly-fetched items.
        /// The length of the array is always the correct number of items in the section.
        /// The keys are kept in sorted order.
        var itemsBySection: JournalingOrderedDictionary<GalleryDate, [MediaGallerySlot], ItemChange> = JournalingOrderedDictionary()
        var hasFetchedOldest = false
        var hasFetchedMostRecent = false
        private(set) var loader: Loader

        /// Loads at least one section before the oldest section, though not any of the items in it.
        ///
        /// Operates in bulk in an attempt to cut down on database traffic, meaning it may measure multiple sections at once.
        ///
        /// Returns the number of new sections loaded, which can be used to update section indexes.
        internal mutating func loadEarlierSections(batchSize: Int, transaction: DBReadTransaction) -> Int {
            guard !hasFetchedOldest else {
                return 0
            }

            var newSlotsByDate: [GalleryDate: [MediaGallerySlot]] = [:]
            let earliestDate = itemsBySection.orderedKeys.first?.interval.start ?? .distantFutureForMillisecondTimestamp

            var newEarliestDate: GalleryDate?
            let result = loader.enumerateTimestamps(
                before: earliestDate,
                count: batchSize,
                transaction: transaction
            ) { datedId in
                let galleryDate = GalleryDate(date: datedId.date)
                let newSlot = MediaGallerySlot(itemId: datedId.id, receivedAt: datedId.date)
                newSlotsByDate[galleryDate, default: []].append(newSlot)
                owsAssertDebug(newEarliestDate == nil || galleryDate <= newEarliestDate!,
                               "expects timestamps to be fetched in descending order")
                newEarliestDate = galleryDate
            }

            if result == .reachedEnd {
                hasFetchedOldest = true
            } else {
                // Make sure we have the full count for the earliest loaded section.
                var temp = newSlotsByDate[newEarliestDate!]!
                newSlotsByDate[newEarliestDate!] = []
                let unloadedRowIdsAndDates = loader.rowIdsAndDatesOfItemsInSection(
                    for: newEarliestDate!,
                    offset: temp.count,
                    ascending: false,
                    transaction: transaction
                )
                let slotsForUnloadedItems = unloadedRowIdsAndDates.lazy.map {
                    MediaGallerySlot(itemId: $0.id, receivedAt: $0.date)
                }
                temp.append(contentsOf: slotsForUnloadedItems)
                newSlotsByDate[newEarliestDate!] = temp
            }

            if itemsBySection.isEmpty {
                hasFetchedMostRecent = true
            }

            let sortedDates = newSlotsByDate.keys.sorted()
            owsAssertDebug(itemsBySection.isEmpty || sortedDates.isEmpty || sortedDates.last! < itemsBySection.orderedKeys.first!)
            for date in sortedDates.reversed() {
                itemsBySection.prepend(key: date, value: newSlotsByDate[date]!.reversed())
            }
            return sortedDates.count
        }

        /// Loads at least one section after the latest section, though not any of the items in it.
        ///
        /// Operates in bulk in an attempt to cut down on database traffic, meaning it may measure multiple sections at once.
        ///
        /// Returns the number of new sections loaded.
        internal mutating func loadLaterSections(batchSize: Int, transaction: DBReadTransaction) -> Int {
            guard batchSize > 0 else {
                owsFailDebug("batch size must be positive")
                return 0
            }
            guard !hasFetchedMostRecent else {
                return 0
            }

            var newSlotsByDate: [GalleryDate: [MediaGallerySlot]] = [:]
            let latestDate = itemsBySection.orderedKeys.last?.interval.end ?? Date(millisecondsSince1970: 0)

            var newLatestDate: GalleryDate?
            let result = loader.enumerateTimestamps(
                after: latestDate,
                count: batchSize,
                transaction: transaction
            ) { datedId in
                let galleryDate = GalleryDate(date: datedId.date)
                newSlotsByDate[galleryDate, default: []].append(
                    MediaGallerySlot(itemId: datedId.id, receivedAt: datedId.date)
                )
                owsAssertDebug(newLatestDate == nil || newLatestDate! <= galleryDate,
                               "expects timestamps to be fetched in ascending order")
                newLatestDate = galleryDate
            }

            if result == .reachedEnd {
                hasFetchedMostRecent = true
            } else {
                // Make sure we have the full count for the latest loaded section.
                var temp = newSlotsByDate[newLatestDate!]!
                newSlotsByDate[newLatestDate!] = []
                let unloadedRowIds = loader.rowIdsAndDatesOfItemsInSection(
                    for: newLatestDate!,
                    offset: temp.count,
                    ascending: true,
                    transaction: transaction
                )
                let slotsForUnloadedItems = unloadedRowIds.map {
                    MediaGallerySlot(itemId: $0.id, receivedAt: $0.date)
                }
                temp.append(contentsOf: slotsForUnloadedItems)
                newSlotsByDate[newLatestDate!] = temp

            }

            if itemsBySection.isEmpty {
                hasFetchedOldest = true
            }

            let sortedDates = newSlotsByDate.keys.sorted()
            owsAssertDebug(itemsBySection.isEmpty || sortedDates.isEmpty || itemsBySection.orderedKeys.last! < sortedDates.first!)
            for date in sortedDates {
                let slots = newSlotsByDate[date]!
                itemsBySection.append(key: date, value: slots)
            }
            return sortedDates.count
        }

        internal mutating func loadInitialSection(for date: GalleryDate, transaction: DBReadTransaction) {
            owsPrecondition(itemsBySection.isEmpty, "already has sections, use loadEarlierSections or loadLaterSections")
            let rowids = loader.rowIdsAndDatesOfItemsInSection(
                for: date,
                offset: 0,
                ascending: true,
                transaction: transaction
            )
            let slots = rowids.map {
                MediaGallerySlot(itemId: $0.id, receivedAt: $0.date)
            }
            itemsBySection.append(key: date, value: slots)
        }

        /// Returns the number of items in the section after reloading (which may be 0).
        @discardableResult
        internal mutating func reloadSection(for date: GalleryDate, transaction: DBReadTransaction) -> Int {
            let rowids = loader.rowIdsAndDatesOfItemsInSection(
                for: date,
                offset: 0,
                ascending: true,
                transaction: transaction
            )
            itemsBySection.replace(key: date) {
                return (
                    rowids.map { MediaGallerySlot(itemId: $0.id, receivedAt: $0.date) },
                    [.reloadSection]
                )
            }
            return rowids.count
        }

        internal mutating func removeEmptySections(atIndexes indexesToDelete: IndexSet) {
            // Delete in reverse order so indexes are preserved as we go.
            for index in indexesToDelete.reversed() {
                owsAssertDebug(itemsBySection[index].value.isEmpty, "section was not empty!")
                itemsBySection.remove(at: index)
            }
        }

        internal mutating func resetHasFetchedMostRecent() {
            hasFetchedMostRecent = false
        }

        internal mutating func reset(transaction: DBReadTransaction) {
            let oldestLoadedSection = itemsBySection.orderedKeys.first
            let newestLoadedSection = itemsBySection.orderedKeys.last
            let numItemsAfterOldestSection = itemsBySection.lazy.dropFirst().map { $0.value.count }.reduce(0, +)

            self = .init(loader: self.loader)

            // Ensure we have a journal entry for the great deletion.
            itemsBySection.removeAll()

            guard let oldestLoadedSection = oldestLoadedSection, let newestLoadedSection = newestLoadedSection else {
                return
            }

            let rowids = loader.rowIdsAndDatesOfItemsInSection(for: oldestLoadedSection,
                                                               offset: 0,
                                                               ascending: true,
                                                               transaction: transaction)
            guard !rowids.isEmpty else {
                // The previous oldest section is gone, so we just have to guess what to load.
                // Try the newest section(s).
                // (We could check if the previous *newest* section is still there, if there's ever a need.)
                _ = self.loadEarlierSections(batchSize: max(1, numItemsAfterOldestSection), transaction: transaction)
                return
            }

            let slots = rowids.map { MediaGallerySlot(itemId: $0.id, receivedAt: $0.date ) }
            itemsBySection.append(key: oldestLoadedSection, value: slots)

            guard oldestLoadedSection != newestLoadedSection else {
                return
            }
            owsAssertDebug(numItemsAfterOldestSection > 1)
            _ = self.loadLaterSections(batchSize: numItemsAfterOldestSection, transaction: transaction)

            // If we haven't gotten to the section we want, keep fetching forward in small-ish batches.
            while !hasFetchedMostRecent, itemsBySection.orderedKeys.last! < newestLoadedSection {
                _ = self.loadLaterSections(batchSize: 10, transaction: transaction)
            }
        }

        internal mutating func replaceLoader(loader: Loader,
                                             batchSize: Int,
                                             loadUntil: GalleryDate,
                                             transaction: DBReadTransaction) {
            self = .init(loader: loader)

            // Ensure there is a journal.
            itemsBySection.removeAll()

            // Load sections until `loadUntil` is all loaded.
            // TODO: Load it all at once rather than in batches.
            while !hasFetchedOldest && (itemsBySection.orderedKeys.first ?? GalleryDate(date: .distantFuture)) > loadUntil {
                _ = loadEarlierSections(batchSize: batchSize, transaction: transaction)
            }
        }

        /// Finds an index path "in the neighborhood" of the given date.
        /// First, try to find an exact match by rowid.
        /// If that fails, try to find the first item with a date on or after itemDate.
        /// If that fails, return the last item.
        /// If the collection is empty, this returns nil.
        internal func indexPathAtApproximateLocation(
            sectionDate: GalleryDate,
            itemDate: Date,
            itemId: AttachmentReferenceId
        ) -> MediaGalleryIndexPath? {
            let si = itemsBySection.orderedKeys.firstIndex { key in
                key >= sectionDate
            }
            guard let si else {
                // Note that this might have a date earlier than `itemDate`.
                return lastIndexPath
            }
            let slots = itemsBySection[si].value

            // First try to find by rowid because that's more precise.
            if let i = slots.firstIndex(where: { slot in slot.itemId == itemId }) {
                return MediaGalleryIndexPath(item: i, section: si)
            }

            // No luck? Find the first item with a later date.
            if let i = slots.firstIndex(where: { slot in slot.receivedAt >= itemDate }) {
                return MediaGalleryIndexPath(item: i, section: si)
            }
            if si + 1 < itemsBySection.orderedKeys.count {
                // Everything in the section of `indexPath` was before the desired date, so return
                // the first item in the subsequent section.
                return MediaGalleryIndexPath(item: 0, section: si + 1)
            }
            // Return the latest item if one exists.
            return lastIndexPath
        }

        private var lastIndexPath: MediaGalleryIndexPath? {
            guard let entry = itemsBySection.last else {
                return nil
            }
            return MediaGalleryIndexPath(item: entry.value.count - 1, section: itemsBySection.orderedKeys.count - 1)
        }

        internal mutating func resolveNaiveStartIndex(request: LoadItemsRequest,
                                                      batchSize: Int,
                                                      transaction: DBReadTransaction?) -> (path: MediaGalleryIndexPath?, numberOfSectionsLoaded: Int) {
            guard let naiveRange = resolveLoadItemsRequest(request) else {
                return (path: nil, numberOfSectionsLoaded: 0)
            }
            return resolveNaiveStartIndex(naiveRange.range.lowerBound,
                                          relativeToSection: naiveRange.sectionIndex,
                                          batchSize: batchSize,
                                          transaction: transaction)
        }

        /// Given `naiveIndex` that refers to an item in or before `initialSectionIndex`, find the actual item and section
        /// index.
        ///
        /// For example, if section 1 has 5 items, `resolveNaiveStartIndex(-2, relativeToSection: 2)` will return
        /// `MediaGalleryIndexPath(item: 3, section: 1)`.
        ///
        /// If the search reaches the first section, `maybeLoadEarlierSections` will be invoked. It should return the
        /// number of sections that have been loaded, which will adjust all section indexes. The default value always
        /// returns 0. If the earliest section has been loaded, this will clamp the index to item 0 in section 0;
        /// otherwise the method returns `nil`.
        ///
        /// This is essentially a more powerful version of `indexPath(before:)`.
        ///
        /// If `transaction` is nonnil then additional earlier sections may be loaded.
        ///
        /// Returns: (The path to the requested index if it can be determined, The number of sections newly loaded)
        internal mutating func resolveNaiveStartIndex(
            _ naiveIndex: Int,
            relativeToSection initialSectionIndex: Int,
            batchSize: Int,
            transaction: DBReadTransaction?
        ) -> (path: MediaGalleryIndexPath?, numberOfSectionsLoaded: Int) {
            guard naiveIndex < 0 else {
                let items = itemsBySection[initialSectionIndex].value
                owsAssertDebug(naiveIndex <= items.count, "should not be used for indexes after the current section")
                return (MediaGalleryIndexPath(item: naiveIndex, section: initialSectionIndex), 0)
            }

            var currentSectionIndex = initialSectionIndex
            var offsetInCurrentSection = naiveIndex
            var totalLoadCount = 0
            while offsetInCurrentSection < 0 {
                if currentSectionIndex == 0 {
                    let newlyLoadedCount: Int
                    if let transaction {
                        newlyLoadedCount = loadEarlierSections(batchSize: batchSize, transaction: transaction)
                    } else {
                        newlyLoadedCount = 0
                    }
                    currentSectionIndex = newlyLoadedCount
                    totalLoadCount += newlyLoadedCount

                    if currentSectionIndex == 0 {
                        if hasFetchedOldest {
                            offsetInCurrentSection = 0
                            break
                        } else {
                            return (nil, totalLoadCount)
                        }
                    }
                }

                currentSectionIndex -= 1
                let items = itemsBySection[currentSectionIndex].value
                offsetInCurrentSection += items.count
            }

            return (MediaGalleryIndexPath(item: offsetInCurrentSection, section: currentSectionIndex), totalLoadCount)
        }

        /// Equivalant to calling the three-argument `resolveNaiveStartIndex` without a transaction.
        internal func resolveNaiveStartIndex(_ naiveIndex: Int, relativeToSection initialSectionIndex: Int) -> MediaGalleryIndexPath? {
            // The five-argument form is `mutating`, but only so it can load more sections.
            // Thanks to Swift's copy-on-write data types, this will only do a few retains even in non-optimized builds.
            var mutableSelf = self
            return mutableSelf.resolveNaiveStartIndex(naiveIndex,
                                                      relativeToSection: initialSectionIndex,
                                                      batchSize: 0,
                                                      transaction: nil).path
        }

        /// Given `naiveIndex` that refers to an end index in or after `initialSectionIndex`, find the actual item and
        /// section index.
        ///
        /// For example, if section 1 has 5 items and section 2 has 3, `resolveNaiveStartIndex(7, relativeToSection: 1)`
        /// will return `MediaGalleryIndexPath(item: 2, section: 2)`. `resolveNaiveStartIndex(5, relativeToSection: 1)` will return
        /// `MediaGalleryIndexPath(item: 5, section: 1)` rather than `MediaGalleryIndexPath(item: 0, section: 2)`.
        ///
        /// If the search reaches the true last section, this will clamp the result to the MediaGalleryIndexPath representing the
        /// end index of the final section (note: not a valid item index!).
        /// If it reaches the last *loaded* section but there might be more sections, it returns nil.
        ///
        /// This is essentially a more powerful version of `indexPath(after:)`.
        internal func resolveNaiveEndIndex(_ naiveIndex: Int, relativeToSection initialSectionIndex: Int) -> MediaGalleryIndexPath? {
            owsPrecondition(naiveIndex >= 0, "should not be used for indexes before the current section")

            var currentSectionIndex = initialSectionIndex
            var limitInCurrentSection = naiveIndex
            while true {
                let items = itemsBySection[currentSectionIndex].value

                if limitInCurrentSection <= items.count {
                    break
                }
                limitInCurrentSection -= items.count
                currentSectionIndex += 1

                if currentSectionIndex == itemsBySection.count {
                    if hasFetchedMostRecent {
                        // Back up to the end of the previous section.
                        currentSectionIndex -= 1
                        limitInCurrentSection = items.count
                        break
                    } else {
                        return nil
                    }
                }
            }

            return MediaGalleryIndexPath(item: limitInCurrentSection, section: currentSectionIndex)
        }

        /// Trims indexes from the start of `naiveRange` if they refer to loaded items.
        ///
        /// Both `naiveRange` and the result may have a negative `startIndex`, which indicates indexing backwards into
        /// previous sections.
        internal func trimLoadedItemsAtStart(from naiveRange: inout Range<Int>, relativeToSection sectionIndex: Int) {
            guard let resolvedIndexPath = resolveNaiveStartIndex(naiveRange.startIndex,
                                                                 relativeToSection: sectionIndex) else {
                // Need to load more sections; can't trim from the start.
                return
            }

            var currentSectionIndex = resolvedIndexPath.section
            var offsetInCurrentSection = resolvedIndexPath.item

            // Now walk forward counting loaded (non-nil) items.
            var countToTrim = 0
            while true {
                let currentSection = itemsBySection[currentSectionIndex].value[offsetInCurrentSection...]
                let countLoadedPrefix = currentSection.prefix { $0.item != nil }.count
                countToTrim += countLoadedPrefix

                if countLoadedPrefix < currentSection.count || currentSectionIndex == sectionIndex {
                    break
                }

                // Start over in the next section at index 0.
                currentSectionIndex += 1
                offsetInCurrentSection = 0
            }

            countToTrim = min(countToTrim, naiveRange.count)
            naiveRange.removeFirst(countToTrim)
        }

        /// Trims indexes from the end of `naiveRange` if they refer to loaded items.
        ///
        /// Both `naiveRange` and the result may have a negative `startIndex`, which indicates indexing backwards into
        /// previous sections. However, the `endIndex` must be non-negative.
        internal func trimLoadedItemsAtEnd(from naiveRange: inout Range<Int>, relativeToSection sectionIndex: Int) {
            // I considered unifying this with trimLoadedItemsAtStart(from:relativeToSection:),
            // but there's just so much that varies even though the control flow is exactly the same.
            guard let resolvedIndexPath = resolveNaiveEndIndex(naiveRange.endIndex,
                                                               relativeToSection: sectionIndex) else {
                // Need to load more sections; can't trim this end.
                return
            }

            var currentSectionIndex = resolvedIndexPath.section
            var limitInCurrentSection = resolvedIndexPath.item

            // Now walk backward counting loaded (non-nil) items.
            var countToTrim = 0
            while true {
                let currentSection = itemsBySection[currentSectionIndex].value[..<limitInCurrentSection]
                let countLoadedSuffix = currentSection.suffix { $0.item != nil }.count
                countToTrim += countLoadedSuffix

                if countLoadedSuffix < currentSection.count || currentSectionIndex == sectionIndex {
                    break
                }

                // Start over from the end of the previous section.
                currentSectionIndex -= 1
                limitInCurrentSection = itemsBySection[currentSectionIndex].value.count
            }

            countToTrim = min(countToTrim, naiveRange.count)
            naiveRange.removeLast(countToTrim)
        }

        // Describes a naïve range using a date instead of a section index. This is more stable when used asynchronously.
        internal struct LoadItemsRequest {
            let date: GalleryDate
            let range: Range<Int>
        }

        internal struct NaiveRange {
            // The section relative to which `naiveRange` is interpreted.
            let sectionIndex: Int

            // This may have at a negative offset, representing a position in a section before `sectionIndex`.
            // Similarly, the endpoint may be in a section that follows `sectionIndex`. However, the range must *cross*
            // `sectionIndex`, or it is not considered valid. `sectionIndex` must refer to a loaded section
            let range: Range<Int>
        }

        /// Constructs a `LoadItemsRequest` if one is needed. Returns `nil` if no items need to be loaded in the requested range.
        internal func loadItemsRequest(in naiveRange: NaiveRange) -> LoadItemsRequest? {
            var trimmedRange = naiveRange.range
            trimLoadedItemsAtStart(from: &trimmedRange, relativeToSection: naiveRange.sectionIndex)
            trimLoadedItemsAtEnd(from: &trimmedRange, relativeToSection: naiveRange.sectionIndex)
            if trimmedRange.isEmpty {
                return nil
            }
            return LoadItemsRequest(date: itemsBySection[naiveRange.sectionIndex].key,
                                    range: trimmedRange)
        }

        /// Calculates the naïve range represented by a `LoadItemsRequest`.
        ///
        /// A naïve range is a range of items relative to the start of a section. The section is identified by an integer index into `itemsBySection`. The range
        /// may fall in part or in whole outside of that section, such as if it has a negative start index.
        ///
        /// This performs a linear search through items in the anchor section and may be slow in the worst case.
        ///
        /// - Returns: A tuple where the first value is a naïve range and the second value is a section index, or nil if it could not be determined because the `LoadItemsRequest` was invalidated by a deletion.
        private func resolveLoadItemsRequest(_ request: LoadItemsRequest) -> NaiveRange? {
            guard let sectionIndex = itemsBySection.orderedKeys.firstIndex(of: request.date) else {
                return nil
            }
            return NaiveRange(sectionIndex: sectionIndex,
                              range: request.range.lowerBound..<request.range.upperBound)
        }

        /// Loads items specified in the request.
        ///
        /// Will open its own database transaction.
        ///
        /// If the start index in the request is non-negative, there will never be any sections loaded before the existing sections. That is:
        /// - When this method starts, we'll have sections like this: [G, H, … J].
        /// - When this method ends, we'll have sections like this: [C, D, … F] [G, H, … J] [K, L, … N],
        ///   where the CDF and KLN chunks could be empty. The returned index set will contain the indexes of C…F and K…N.
        ///
        /// Returns the indexes of newly loaded *sections,* which could shift the indexes of existing sections. These will
        /// always be before and/or after the existing sections, never interleaving.
        internal mutating func ensureItemsLoaded(request: LoadItemsRequest,
                                                 transaction: DBReadTransaction) -> IndexSet {
            guard let naiveRange = resolveLoadItemsRequest(request) else {
                return IndexSet()
            }
            owsPrecondition(!naiveRange.range.isEmpty)

            var numNewlyLoadedEarlierSections: Int = 0
            var numNewlyLoadedLaterSections: Int = 0

            // Figure out the earliest section this request will cross.
            // Note that this is a bigger batch size than necessary:
            // -trimmedRange.startIndex would be sufficient,
            // and resolveNaiveStartIndex(...) could give us the exact offset we need.
            // However, the media gallery is a scrolling collection view that most commonly starts at the
            // present and scrolls up into the past; if we are ensuring loaded items in earlier sections, we are
            // likely actively scrolling. Because of this, we potentially measure some extra sections here so
            // that we don't have to on the immediate next call to ensureItemsLoaded(...).
            let (requestStartPath, newlyLoadedCount) = resolveNaiveStartIndex(naiveRange.range.startIndex,
                                                                              relativeToSection: naiveRange.sectionIndex,
                                                                              batchSize: naiveRange.range.count,
                                                                              transaction: transaction)
            numNewlyLoadedEarlierSections = newlyLoadedCount
            guard let requestStartPath = requestStartPath else {
                owsFail("failed to resolve despite loading \(numNewlyLoadedEarlierSections) earlier sections")
            }

            var currentSectionIndex = requestStartPath.section
            let interval = DateInterval(start: itemsBySection.orderedKeys[currentSectionIndex].interval.start,
                                        end: .distantFutureForMillisecondTimestamp)
            let requestRange = requestStartPath.item ..< (requestStartPath.item + naiveRange.range.count)

            var offset = 0
            loader.enumerateItems(
                in: interval,
                range: requestRange,
                transaction: transaction
            ) { i, resourceId, buildItem in
                owsAssertDebug(i >= offset, "does not support reverse traversal")

                var (date, slots) = itemsBySection[currentSectionIndex]
                var itemIndex = i - offset

                while itemIndex >= slots.count {
                    itemIndex -= slots.count
                    offset += slots.count
                    currentSectionIndex += 1

                    if currentSectionIndex >= itemsBySection.count {
                        if hasFetchedMostRecent {
                            // Ignore later attachments.
                            owsAssertDebug(itemsBySection.count == 1, "should only be used in single-album page view")
                            return
                        }
                        numNewlyLoadedLaterSections += loadLaterSections(batchSize: naiveRange.range.count,
                                                                         transaction: transaction)
                        if currentSectionIndex >= itemsBySection.count {
                            owsFailDebug("attachment #\(i) \(resourceId) is beyond the last section")
                            return
                        }
                    }

                    (date, slots) = itemsBySection[currentSectionIndex]
                }

                var slot = slots[itemIndex]
                if let loadedItem = slot.item {
                    owsPrecondition(loadedItem.attachmentId == resourceId)
                    return
                }

                itemsBySection.replace(key: date) {
                    let item = buildItem()
                    owsAssertDebug(item.galleryDate == date,
                                   "item from \(item.galleryDate) put into section for \(date)")

                    slot.item = item
                    slots[itemIndex] = slot
                    return (slots, [.updateItem(index: itemIndex)])
                }
            }

            let firstNewLaterSectionIndex = itemsBySection.count - numNewlyLoadedLaterSections
            var newlyLoadedSections = IndexSet()
            newlyLoadedSections.insert(integersIn: 0..<numNewlyLoadedEarlierSections)
            newlyLoadedSections.insert(integersIn: firstNewLaterSectionIndex..<itemsBySection.count)
            return newlyLoadedSections
        }

        internal mutating func getOrReplaceItem(_ newItem: Item, offsetInSection: Int) -> Item? {
            // Assume we've set up this section, but may or may not have initialized the item.
            guard var items = itemsBySection[newItem.galleryDate] else {
                owsFailDebug("section for focused item not found")
                return nil
            }
            guard offsetInSection < items.count else {
                owsFailDebug("offset is out of bounds in section")
                return nil
            }

            if let existingItem = items[offsetInSection].item {
                return existingItem
            }

            // Swap out the section items to avoid copy-on-write.
            itemsBySection.replace(key: newItem.galleryDate) {
                items[offsetInSection].item = newItem
                return (items, [.updateItem(index: offsetInSection)])
            }
            return newItem
        }

        /// Removes a set of items by their paths.
        ///
        /// If any sections are reduced to zero items, they are removed from the model. The indexes of all such removed
        /// sections are returned.
        internal mutating func removeLoadedItems(atIndexPaths paths: [MediaGalleryIndexPath]) -> IndexSet {
            var removedSections = IndexSet()

            // Iterate in reverse so the index paths don't get disrupted as we remove items.
            for path in paths.sorted().reversed() {
                let sectionKey = itemsBySection.orderedKeys[path.section]
                // Swap out / swap in to avoid copy-on-write.
                var section = itemsBySection[sectionKey]!
                itemsBySection.replace(key: sectionKey) {
                    if section.remove(at: path.item).item == nil {
                        owsFailDebug("removed an item that wasn't loaded, which isn't permitted")
                    }

                    if section.isEmpty {
                        removedSections.insert(path.section)
                        return nil
                    }
                    return (section, [.removeItem(index: path.item)])
                }
            }

            return removedSections
        }
    }

    enum ItemChange: CustomDebugStringConvertible, Equatable {
        var debugDescription: String {
            switch self {
            case .reloadSection:
                return "reloadSection"
            case .updateItem(index: let index):
                return "updateItem(index: \(index))"
            case .removeItem(index: let index):
                return "removeItem(index: \(index))"
            }
        }
        case reloadSection
        case updateItem(index: Int)
        case removeItem(index: Int)
    }

    /// An `Update` holds the information necessary to make one or more mutations effective by
    /// `commit()`ing it, as well accruing related journals and user data.
    ///
    /// The main reason for the existence of `Update` is that it's useful for
    /// clients to have control over when the snapshot changes, and it allows
    /// them to commit the snapshot when they are ready. Additionally, clients
    /// may find it useful to attach metadata to a mutation: `Update` stores
    /// them so the journal and associated metadata for mutation are bundled
    /// together.
    public class Update {
        static var noop: Update {
            Update(journal: [], userData: nil) {}
        }

        typealias Journal = [JournalingOrderedDictionaryChange<ItemChange>]
        private(set) var journal: Journal
        private var commitSnapshot: (() -> Void)?
        private(set) var userData = [UpdateUserData]()

        var hasBeenCommitted: Bool {
            return journal.isEmpty && commitSnapshot == nil
        }

        func merge(from following: Update) {
            journal.append(contentsOf: following.journal)
            userData.append(contentsOf: following.userData)
            commitSnapshot = following.commitSnapshot
        }

        func commit() -> Journal {
            commitSnapshot?()
            commitSnapshot = nil
            defer {
                journal = []
                userData = []
            }
            return journal
        }

        init(journal: Journal,
             userData: UpdateUserData?,
             commitSnapshot: @escaping (() -> Void)) {
            self.journal = journal
            self.userData = userData.map { [$0] } ?? []
            self.commitSnapshot = commitSnapshot
        }
    }

    class SnapshotManager {
        private var mutableState: State
        private var snapshot: State
        private(set) var pendingUpdate = AtomicValue(Update.noop, lock: .init())
        private var highPriorityStack: AtomicArray<() -> Void> = AtomicArray(lock: .sharedGlobal)
        private var lowPriorityStack: AtomicArray<() -> Void> = AtomicArray(lock: .sharedGlobal)
        // We tried to use an OperationQueue for this. It was a good fit because it can prioritize
        // synchronous operations ahead of async ones. We ended up getting weird crashes in the Swift
        // runtime. The best theory was that OperationQueue is missing a memory barrier, but that isn't
        // much more than speculation. This queue is essentially a background thread that performs async
        // operations and all mutations are guarded by `lock` to do synchronization.
        private let queue = DispatchQueue(label: "org.signal.mgs-snapshot")
        // It's important that this lock be fair so that synchronous mutations run as soon as possible.
        private let lock = NSLock()

        var state: State {
            dispatchPrecondition(condition: .onQueue(.main))
            return snapshot
        }

        init(state: State) {
            self.mutableState = state
            self.snapshot = state
        }

        // Runs on the mutation queue.
        private func _mutate<T>(userData: UpdateUserData?, _ block: (inout State) -> (T)) -> T {
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            let result = block(&mutableState)
            let updatedState = mutableState
            let changes = mutableState.itemsBySection.takeJournal()
            let update = Update(journal: changes, userData: userData) { [weak self] in
                self?.snapshot = updatedState
            }
            pendingUpdate.map { pendingUpdate in
                pendingUpdate.merge(from: update)
                return pendingUpdate
            }
            return result
        }

        private var depthReport: String {
            return "H=\(highPriorityStack.count) L=\(lowPriorityStack.count)"
        }

        func mutate<T>(userData: UpdateUserData?, _ block: (inout State) -> (T)) -> T {
            dispatchPrecondition(condition: .onQueue(.main))
            return Bench(title: "Sync mutation [\(depthReport)]", logIfLongerThan: 0.1, logInProduction: true) {
                return self._mutate(userData: userData, block)
            }
        }

        func mutate<T>(userData: UpdateUserData?, _ block: (inout State, DBReadTransaction) -> (T)) -> T {
            return mutate(userData: userData) { mutableState in
                return SSKEnvironment.shared.databaseStorageRef.read { transaction in
                    return block(&mutableState, transaction)
                }
            }
        }

        func cancelAsyncJobs() {
            highPriorityStack.removeAll()
            lowPriorityStack.removeAll()
        }

        /// Runs `block` on the mutation queue and then runs `completion` on the main queue, but the main queue is not
        /// blocked while waiting for `block` to complete.
        ///
        /// Note that mutations go on a stack rather than a queue. The last call to `mutateAsync` will be the first one to run after any current operation completes.
        ///
        /// All `highPriority` mutations will occur before any low-priority mutation. Clients are advised to treat user-initiated updates as high-priority.
        func mutateAsync<T>(userData: UpdateUserData?,
                            highPriority: Bool,
                            title: String?,
                            _ block: @escaping (inout State) -> (T),
                            completion: @escaping (T) -> Void) {
            dispatchPrecondition(condition: .onQueue(.main))
            let closure = { [weak self] in
                guard let self else {
                    return
                }
                dispatchPrecondition(condition: .onQueue(self.queue))
                Bench(title: "Async mutation of \(title ?? "untitled") [\(self.depthReport)]", logInProduction: true) {
                    let result = self._mutate(userData: userData, block)
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            }
            (highPriority ? highPriorityStack : lowPriorityStack).pushTail(closure)
            queue.async { [weak self] in
                let closure = self?.highPriorityStack.popTail() ?? self?.lowPriorityStack.popTail()
                closure?()
            }
        }

        func mutateAsync<T>(userData: UpdateUserData?,
                            highPriority: Bool,
                            title: String? = nil,
                            _ block: @escaping (inout State, DBReadTransaction) -> (T),
                            completion: @escaping (T) -> Void) {
            mutateAsync(userData: userData, highPriority: highPriority, title: title) { mutableState in
                return SSKEnvironment.shared.databaseStorageRef.read { transaction in
                    block(&mutableState, transaction)
                }
            } completion: { value in
                completion(value)
            }
        }
    }

    private var snapshotManager: SnapshotManager
    private var state: State { snapshotManager.state }

    var stateForTesting: State { state }
    var snapshotManagerForTesting: SnapshotManager { snapshotManager }

    internal init(loader: Loader) {
        snapshotManager = SnapshotManager(state: State(loader: loader))
    }

    /// Executes `closure` with exclusive access to the pending update. It must not escape the
    /// closure. This is just here for the benefit of tests.
    func accessPendingUpdate(_ closure: (Update) -> Void) {
        snapshotManager.pendingUpdate.map { pendingUpdate in
            closure(pendingUpdate)
            return pendingUpdate
        }
    }

    // Atomically replaces `pendingUpdate` with an empty instance and returns the original.
    func takePendingUpdate() -> Update {
        return snapshotManager.pendingUpdate.swap(Update.noop)
    }

    // MARK: Sections

    internal mutating func loadEarlierSections(batchSize: Int, userData: UpdateUserData? = nil) -> Int {
        return snapshotManager.mutate(userData: userData) { state, transaction in
            return state.loadEarlierSections(batchSize: batchSize, transaction: transaction)
        }
    }

    // Warning: the completion block may not be called if the loader is replaced before the job begins.
    internal mutating func asyncLoadEarlierSections(batchSize: Int,
                                                    highPriority: Bool,
                                                    userData: UpdateUserData? = nil,
                                                    completion: ((Int) -> Void)?) {
        snapshotManager.mutateAsync(userData: userData, highPriority: highPriority, title: "load earlier section") { state, transaction in
            return state.loadEarlierSections(batchSize: batchSize, transaction: transaction)
        } completion: { numberOfSectionsLoaded in
            completion?(numberOfSectionsLoaded)
        }
    }

    internal mutating func loadLaterSections(batchSize: Int, userData: UpdateUserData? = nil) -> Int {
        return snapshotManager.mutate(userData: userData) { state, transaction in
            return state.loadLaterSections(batchSize: batchSize, transaction: transaction)
        }
    }

    // Warning: the completion block may not be called if the loader is replaced before the job begins.
    internal mutating func asyncLoadLaterSections(batchSize: Int,
                                                  userData: UpdateUserData? = nil,
                                                  completion: ((Int) -> Void)?) {
        snapshotManager.mutateAsync(userData: userData, highPriority: true, title: "load later sections") { state, transaction in
            return state.loadLaterSections(batchSize: batchSize, transaction: transaction)
        } completion: { numberOfSectionsLoaded in
            completion?(numberOfSectionsLoaded)
        }

    }

    /// If `replacement` is specified then this acts as an atomic
    /// `loadInitialSection` followed by `getOrReplace`, provided the `rowid` is
    /// valid.
    internal mutating func loadInitialSection(
        for date: GalleryDate,
        replacement: (item: Item, itemId: AttachmentReferenceId)? = nil,
        userData: UpdateUserData? = nil,
        transaction: DBReadTransaction
    ) -> Item? {
        return snapshotManager.mutate(userData: userData) { state in
            state.loadInitialSection(for: date, transaction: transaction)
            if let (item, itemId) = replacement,
                let offset = state.itemsBySection[date]?.firstIndex(where: { $0.itemId == itemId }) {
                return state.getOrReplaceItem(item, offsetInSection: offset)
            }
            return nil
        }
    }

    @discardableResult
    internal mutating func reloadSections(for dates: Set<GalleryDate>,
                                          userData: UpdateUserData? = nil) -> (update: IndexSet, delete: IndexSet) {
        return snapshotManager.mutate(userData: userData) { state, transaction in
            var sectionIndexesNeedingUpdate = IndexSet()
            var sectionsToDelete = IndexSet()
            for sectionDate in dates {
                // Scan backwards; newer items are more likely to be modified.
                // (We could use a binary search here as well.)
                guard let sectionIndex = state.itemsBySection.orderedKeys.lastIndex(of: sectionDate) else {
                    continue
                }

                // Refresh the section.
                let newCount = state.reloadSection(for: sectionDate, transaction: transaction)

                sectionIndexesNeedingUpdate.insert(sectionIndex)
                if newCount == 0 {
                    sectionsToDelete.insert(sectionIndex)
                }
            }
            state.removeEmptySections(atIndexes: sectionsToDelete)
            return (update: sectionIndexesNeedingUpdate, delete: sectionsToDelete)
        }
    }

    @discardableResult
    internal mutating func reloadSection(for date: GalleryDate,
                                         userData: UpdateUserData? = nil) -> Int {
        return snapshotManager.mutate(userData: userData) { state, transaction in
            return state.reloadSection(for: date, transaction: transaction)
        }
    }

    internal mutating func resetHasFetchedMostRecent(userData: UpdateUserData? = nil) {
        return snapshotManager.mutate(userData: userData) { state in
            state.resetHasFetchedMostRecent()
        }
    }

    internal mutating func reset(userData: UpdateUserData? = nil) {
        return snapshotManager.mutate(userData: userData) { state, transaction in
            state.reset(transaction: transaction)
        }
    }

    /// Erase all state and reload.
    ///
    /// This method has the side effect of canceling all unstarted asynchronous jobs. Their
    /// completion blocks will never be called.
    ///
    /// - Parameters:
    ///   - batchSize: The number of items to load at once.
    ///   - loadUntil: Items will be loaded from latest until the GalleryDate containing this date is completely loaded.
    ///   - indexPath: A valid index path.
    ///   - userData: user data
    ///   - first: Called on the mutation queue just before reloading occurs. If you need to update the loader's state, this is a safe place to do it.
    /// - Returns: An index path as close as possible to `indexPath`.
    internal mutating func replaceLoader(loader: Loader,
                                         batchSize: Int,
                                         loadUntil: GalleryDate,
                                         searchFor indexPath: MediaGalleryIndexPath?,
                                         userData: UpdateUserData? = nil) -> MediaGalleryIndexPath? {
        snapshotManager.cancelAsyncJobs()

        let sectionDate = indexPath.map { sectionDates[$0.section] }
        let itemDate = indexPath.map { itemsBySection[$0.section].value[$0.item].receivedAt }
        let itemId = indexPath.map { itemsBySection[$0.section].value[$0.item].itemId }

        return snapshotManager.mutate(userData: nil) { state, transaction -> MediaGalleryIndexPath? in
            state.replaceLoader(loader: loader, batchSize: batchSize, loadUntil: loadUntil, transaction: transaction)
            if let sectionDate, let itemDate, let itemId {
                return state.indexPathAtApproximateLocation(
                    sectionDate: sectionDate,
                    itemDate: itemDate,
                    itemId: itemId
                )
            }
            return nil
        }
    }

    internal struct NewAttachmentHandlingResult: Equatable {
        var update = IndexSet()
        var didAddAtEnd = false
        var didReset = false
    }

    internal mutating func handleNewAttachments(_ dates: some Sequence<GalleryDate>,
                                                userData: UpdateUserData? = nil) -> NewAttachmentHandlingResult {
        return snapshotManager.mutate(userData: userData) { state, transaction in
            var result = NewAttachmentHandlingResult()

            for sectionDate in dates {
                // Do a backwards search assuming new messages usually arrive at the end.
                // Still, this is kept sorted, so we ought to be able to do a binary search instead.
                if let lastSectionDate = state.itemsBySection.orderedKeys.last, sectionDate > lastSectionDate {
                    // Only let clients know about the new section if they thought they were at the end;
                    // otherwise they'll fetch more if they need to.
                    if state.hasFetchedMostRecent {
                        state.resetHasFetchedMostRecent()
                        result.didAddAtEnd = true
                    }
                } else if let sectionIndex = state.itemsBySection.orderedKeys.lastIndex(of: sectionDate) {
                    result.update.insert(sectionIndex)
                } else if state.itemsBySection.isEmpty {
                    if state.hasFetchedMostRecent {
                        state.resetHasFetchedMostRecent()
                    }
                    result.didAddAtEnd = true
                } else {
                    // We've loaded the first attachment in a new section that's not at the end. That can't be done
                    // transparently in MediaGallery's model, so let all our delegates know to refresh *everything*.
                    // This should be rare, but can happen if someone has automatic attachment downloading off and then
                    // goes back and downloads an attachment that crosses the month boundary.
                    state.reset(transaction: transaction)
                    result.didReset = true
                    return result
                }
            }

            for sectionIndex in result.update {
                // Throw out everything in that section.
                let sectionDate = state.itemsBySection.orderedKeys[sectionIndex]
                state.reloadSection(for: sectionDate, transaction: transaction)
            }

            return result
        }
    }

    // MARK: Items

    /// Returns the item at `path`, which will be `nil` if not yet loaded.
    ///
    /// `path` must be a valid path for the items currently loaded.
    internal func loadedItem(at path: MediaGalleryIndexPath) -> Item? {
        owsPrecondition(path.count == 2)
        guard let slot = state.itemsBySection[safe: path.section]?.value[safe: path.item] else {
            owsFailDebug("invalid path \(path)")
            return nil
        }
        // The result might still be nil if the item hasn't been loaded.
        return slot.item
    }

    /// Searches the appropriate section for this item by its `galleryDate` and `uniqueId`.
    ///
    /// Will return nil if the item is not in `state.itemsBySection` (say, if it was loaded externally).
    internal func indexPath(for item: Item) -> MediaGalleryIndexPath? {
        // Search backwards because people view recent items.
        // Note: we could use binary search because orderedKeys is sorted.
        guard let sectionIndex = state.itemsBySection.orderedKeys.lastIndex(of: item.galleryDate),
              let itemIndex = state.itemsBySection[sectionIndex].value.lastIndex(where: {
                  $0.item?.attachmentId == item.attachmentId
              }) else {
            return nil
        }

        return MediaGalleryIndexPath(item: itemIndex, section: sectionIndex)
    }

    /// Returns the path to the next item after `path`, which may cross a section boundary.
    ///
    /// If `path` refers to the last item in the loaded sections, returns `nil`.
    internal func indexPath(after path: MediaGalleryIndexPath) -> MediaGalleryIndexPath? {
        owsPrecondition(path.count == 2)
        var result = path

        // Next item?
        result.item += 1
        if result.item < state.itemsBySection[result.section].value.count {
            return result
        }

        // Next section?
        result.item = 0
        result.section += 1
        if result.section < state.itemsBySection.count {
            owsAssertDebug(!state.itemsBySection[result.section].value.isEmpty, "no empty sections")
            return result
        }

        // Reached the end.
        return nil
    }

    /// Returns the path to the item just before `path`, which may cross a section boundary.
    ///
    /// If `path` refers to the first item in the loaded sections, returns `nil`.
    internal func indexPath(before path: MediaGalleryIndexPath) -> MediaGalleryIndexPath? {
        owsPrecondition(path.count == 2)
        var result = path

        // Previous item?
        if result.item > 0 {
            result.item -= 1
            return result
        }

        // Previous section?
        if result.section > 0 {
            result.section -= 1
            owsAssertDebug(!state.itemsBySection[result.section].value.isEmpty, "no empty sections")
            result.item = state.itemsBySection[result.section].value.count - 1
            return result
        }

        // Reached the start.
        return nil
    }

    internal func trimLoadedItemsAtStart(from naiveRange: inout Range<Int>,
                                         relativeToSection sectionIndex: Int) {
        state.trimLoadedItemsAtStart(from: &naiveRange,
                                     relativeToSection: sectionIndex)
    }

    internal func trimLoadedItemsAtEnd(from naiveRange: inout Range<Int>, relativeToSection sectionIndex: Int) {
        state.trimLoadedItemsAtEnd(from: &naiveRange,
                                   relativeToSection: sectionIndex)
    }

    internal mutating func ensureItemsLoaded(in naiveRange: Range<Int>,
                                             relativeToSection sectionIndex: Int,
                                             userData: UpdateUserData? = nil) -> IndexSet {
        guard let request = state.loadItemsRequest(in: State.NaiveRange(sectionIndex: sectionIndex, range: naiveRange)) else {
            return IndexSet()
        }
        return snapshotManager.mutate(userData: userData) { state in
            return SSKEnvironment.shared.databaseStorageRef.read { transaction in
                return state.ensureItemsLoaded(request: request,
                                               transaction: transaction)
            }
        }
    }

    // Warning: the completion block may not be called if the loader is replaced before the job begins.
    internal mutating func asyncEnsureItemsLoaded(in naiveRange: Range<Int>,
                                                  relativeToSection sectionIndex: Int,
                                                  userData: UpdateUserData? = nil,
                                                  completion: @escaping (IndexSet) -> Void) {
        guard let request = state.loadItemsRequest(in: State.NaiveRange(sectionIndex: sectionIndex, range: naiveRange)) else {
            DispatchQueue.main.async {
                completion(IndexSet())
            }
            return
        }
        snapshotManager.mutateAsync(userData: userData, highPriority: true, title: "ensure \(naiveRange.count) items loaded") { state, transaction in
            return state.ensureItemsLoaded(request: request,
                                           transaction: transaction)
        } completion: { newlyLoadedSectionIndexes in
            completion(newlyLoadedSectionIndexes)
        }

    }

    internal mutating func getOrReplaceItem(
        _ newItem: Item,
        itemId: AttachmentReferenceId,
        userData: UpdateUserData? = nil
    ) -> Item? {
        return snapshotManager.mutate(userData: userData) { state in
            guard let i = state.itemsBySection[newItem.galleryDate]?.firstIndex(where: { $0.itemId == itemId}) else {
                return nil
            }
            return state.getOrReplaceItem(newItem, offsetInSection: i)
        }
    }

    private struct Location {
        var date: GalleryDate
        var itemId: AttachmentReferenceId
    }

    internal mutating func removeLoadedItems(atIndexPaths paths: [MediaGalleryIndexPath],
                                             userData: UpdateUserData? = nil) -> IndexSet {
        let locations = paths.map {
            let entry = state.itemsBySection[$0.section]
            return Location(date: entry.key, itemId: entry.value[$0.item].itemId)
        }
        return snapshotManager.mutate(userData: userData) { state -> IndexSet in
            // [date: [rowid, …]]
            let sectionIndexToItemIDs = Dictionary(grouping: locations) {
                $0.date
            }.mapValues {
                Set($0.lazy.map { $0.itemId })
            }
            let paths = sectionIndexToItemIDs.flatMap { keyAndValue -> [MediaGalleryIndexPath] in
                let (date, desiredItemIDs) = keyAndValue
                guard let sectionIndex = state.itemsBySection.orderedKeys.firstIndex(of: date) else {
                    return []
                }
                let slots = state.itemsBySection[sectionIndex].value
                let itemIndexes = slots.indices.lazy.filter { desiredItemIDs.contains(slots[$0].itemId) }
                return itemIndexes.lazy.map { MediaGalleryIndexPath(item: $0, section: sectionIndex )}
            }
            return state.removeLoadedItems(atIndexPaths: Array(paths))
        }
    }

    // MARK: Passthrough members

    internal var isEmpty: Bool { state.itemsBySection.isEmpty }
    internal var sectionDates: [GalleryDate] { state.itemsBySection.orderedKeys }
    internal var hasFetchedMostRecent: Bool { state.hasFetchedMostRecent }
    internal var hasFetchedOldest: Bool { state.hasFetchedOldest }
    internal var itemsBySection: OrderedDictionary<GalleryDate, [MediaGallerySlot]> { state.itemsBySection.orderedDictionary }
}

fileprivate extension JournalingOrderedDictionary where ValueType: ExpressibleByArrayLiteral {
    /// This is a convenience method that provides a performance optimization to delete or set the value of an already-existing key.
    /// By using this method, you avoid having two different copies of the value in memory. That could cause a copy-on-write for a value that's about to disappear.
    /// A closure rather than a value is used so the value in the underlying dictionary can be removed before forcing the new value to exist.
    ///
    /// Example usage:
    ///
    ///     if var value = dict["my key"] {  // value is of type [String]
    ///         dict.replace("my key") {
    ///            value.append("foo")
    ///            return (value, [.replace])
    ///         }
    ///     }
    ///
    /// If the closure returns `nil` then the key is removed from the dictionary.
    mutating func replace(key: KeyType, closure: () -> (ValueType, [ChangeType])?) {
        let i = orderedKeys.firstIndex(of: key)!
        // Performance hack: clear out the current 'items' array in 'sections' to avoid copy-on-write.
        replaceValue(at: i, value: [], changes: [])
        if let tuple = closure() {
            let (newValue, changes) = tuple
            replaceValue(at: i, value: newValue, changes: changes)
        } else {
            remove(at: i)
        }
    }
}
