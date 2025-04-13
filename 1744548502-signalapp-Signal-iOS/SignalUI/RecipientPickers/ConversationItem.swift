//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import SignalServiceKit

public enum MessageRecipient: Equatable {
    case contact(_ address: SignalServiceAddress)
    case group(_ groupThreadId: String)
    case privateStory(_ storyThreadId: String, isMyStory: Bool)
}

// MARK: -

public enum ConversationItemMessageType: Equatable, Hashable {
    case message
    case storyMessage
}

public protocol ConversationItem {
    var messageRecipient: MessageRecipient { get }

    func title(transaction: DBReadTransaction) -> String

    var outgoingMessageType: ConversationItemMessageType { get }

    var image: UIImage? { get }
    var isBlocked: Bool { get }
    var isStory: Bool { get }
    var disappearingMessagesConfig: OWSDisappearingMessagesConfiguration? { get }

    func getExistingThread(transaction: DBReadTransaction) -> TSThread?
    func getOrCreateThread(transaction: DBWriteTransaction) -> TSThread?

    /// If true, attachments will be segmented into chunks shorter than
    /// `StoryMessage.videoAttachmentDurationLimit` and limited in quality.
    var limitsVideoAttachmentLengthForStories: Bool { get }

    /// If non-nill, tooltip text that will be shown when attempting to send a video to this
    /// conversation that exceeds the story video attachment duration.
    /// Should be set if `limitsVideoAttachmentLengthForStories` is true.
    var videoAttachmentStoryLengthTooltipString: String? { get }
}

extension ConversationItem {
    public var titleWithSneakyTransaction: String { SSKEnvironment.shared.databaseStorageRef.read { title(transaction: $0) } }

    public var videoAttachmentDurationLimit: TimeInterval? {
        return limitsVideoAttachmentLengthForStories ? StoryMessage.videoAttachmentDurationLimit : nil
    }

    public var videoAttachmentStoryLengthTooltipString: String? {
        if limitsVideoAttachmentLengthForStories {
            owsFailDebug("Should set if limitsVideoAttachmentLengthForStories is true.")
        }
        return nil
    }
}

// MARK: -

struct RecentConversationItem {
    enum ItemType {
        case contact(_ item: ContactConversationItem)
        case group(_ item: GroupConversationItem)
    }

    let backingItem: ItemType
    var unwrapped: ConversationItem {
        switch backingItem {
        case .contact(let contactItem):
            return contactItem
        case .group(let groupItem):
            return groupItem
        }
    }
}

// MARK: -

extension RecentConversationItem: ConversationItem {
    var outgoingMessageType: ConversationItemMessageType { unwrapped.outgoingMessageType }

    var limitsVideoAttachmentLengthForStories: Bool { return unwrapped.limitsVideoAttachmentLengthForStories }

    var messageRecipient: MessageRecipient {
        return unwrapped.messageRecipient
    }

    func title(transaction: DBReadTransaction) -> String {
        return unwrapped.title(transaction: transaction)
    }

    var image: UIImage? {
        return unwrapped.image
    }

    var isBlocked: Bool {
        return unwrapped.isBlocked
    }

    var isStory: Bool { return false }

    var disappearingMessagesConfig: OWSDisappearingMessagesConfiguration? {
        return unwrapped.disappearingMessagesConfig
    }

    func getExistingThread(transaction: DBReadTransaction) -> TSThread? {
        return unwrapped.getExistingThread(transaction: transaction)
    }

    func getOrCreateThread(transaction: DBWriteTransaction) -> TSThread? {
        return unwrapped.getOrCreateThread(transaction: transaction)
    }
}

// MARK: -

struct ContactConversationItem {
    let address: SignalServiceAddress
    let isBlocked: Bool
    let disappearingMessagesConfig: OWSDisappearingMessagesConfiguration?
    let comparableName: ComparableDisplayName

    init(
        address: SignalServiceAddress,
        isBlocked: Bool,
        disappearingMessagesConfig: OWSDisappearingMessagesConfiguration?,
        comparableName: ComparableDisplayName
    ) {
        owsAssertBeta(
            !isBlocked,
            "Should never get here with a blocked contact!"
        )

        self.address = address
        self.isBlocked = isBlocked
        self.disappearingMessagesConfig = disappearingMessagesConfig
        self.comparableName = comparableName
    }

    public static func < (lhs: ContactConversationItem, rhs: ContactConversationItem) -> Bool {
        return lhs.comparableName < rhs.comparableName
    }
}

// MARK: -

extension ContactConversationItem: ConversationItem {
    var outgoingMessageType: ConversationItemMessageType { .message }

    var isStory: Bool { return false }

    var limitsVideoAttachmentLengthForStories: Bool { return false }

    var messageRecipient: MessageRecipient {
        .contact(address)
    }

    func title(transaction: DBReadTransaction) -> String {
        guard !address.isLocalAddress else {
            return MessageStrings.noteToSelf
        }

        return comparableName.resolvedValue()
    }

    var image: UIImage? {
        let contactManager = SSKEnvironment.shared.contactManagerImplRef
        let databaseStorage = SSKEnvironment.shared.databaseStorageRef
        return databaseStorage.read { tx in
            return contactManager.avatarImage(forAddress: self.address, transaction: tx)
        }
    }

    func getExistingThread(transaction: DBReadTransaction) -> TSThread? {
        return TSContactThread.getWithContactAddress(address, transaction: transaction)
    }

    func getOrCreateThread(transaction: DBWriteTransaction) -> TSThread? {
        return TSContactThread.getOrCreateThread(withContactAddress: address, transaction: transaction)
    }
}

// MARK: -

public struct GroupConversationItem {
    public let groupThreadId: String
    public let isBlocked: Bool
    public let disappearingMessagesConfig: OWSDisappearingMessagesConfiguration?

    init(
        groupThreadId: String,
        isBlocked: Bool,
        disappearingMessagesConfig: OWSDisappearingMessagesConfiguration?
    ) {
        owsAssertBeta(
            !isBlocked,
            "Should never get here with a blocked group!"
        )

        self.groupThreadId = groupThreadId
        self.isBlocked = isBlocked
        self.disappearingMessagesConfig = disappearingMessagesConfig
    }

    // We don't want to keep this in memory, because the group model
    // can be very large.
    public var groupThread: TSGroupThread? {
        SSKEnvironment.shared.databaseStorageRef.read { transaction in
            return TSGroupThread.anyFetchGroupThread(uniqueId: groupThreadId, transaction: transaction)
        }
    }

    public var groupModel: TSGroupModel? {
        groupThread?.groupModel
    }
}

// MARK: -

extension GroupConversationItem: ConversationItem {
    public var outgoingMessageType: ConversationItemMessageType { .message }

    public var isStory: Bool { return false }

    public var limitsVideoAttachmentLengthForStories: Bool { return false }

    public var messageRecipient: MessageRecipient {
        .group(groupThreadId)
    }

    public func title(transaction: DBReadTransaction) -> String {
        guard let groupThread = getExistingThread(transaction: transaction) as? TSGroupThread else {
            return TSGroupThread.defaultGroupName
        }
        return groupThread.groupNameOrDefault
    }

    public var image: UIImage? {
        guard let groupThread = groupThread else { return nil }
        return SSKEnvironment.shared.databaseStorageRef.read { transaction in
            SSKEnvironment.shared.avatarBuilderRef.avatarImage(forGroupThread: groupThread,
                                                               diameterPoints: AvatarBuilder.standardAvatarSizePoints,
                                                               transaction: transaction)
        }
    }

    public func getExistingThread(transaction: DBReadTransaction) -> TSThread? {
        return TSGroupThread.anyFetchGroupThread(uniqueId: groupThreadId, transaction: transaction)
    }

    public func getOrCreateThread(transaction: DBWriteTransaction) -> TSThread? {
        return getExistingThread(transaction: transaction)
    }
}

// MARK: -

public struct StoryConversationItem {
    public enum ItemType {
        case groupStory(_ item: GroupConversationItem)
        case privateStory(_ item: PrivateStoryConversationItem)
    }

    public var threadId: String {
        switch backingItem {
        case .groupStory(let item): return item.groupThreadId
        case .privateStory(let item): return item.storyThreadId
        }
    }

    public let backingItem: ItemType
    var unwrapped: ConversationItem {
        switch backingItem {
        case .groupStory(let item): return item
        case .privateStory(let item): return item
        }
    }

    public var storyState: StoryContextViewState?

    public static func allItems(
        includeImplicitGroupThreads: Bool,
        excludeHiddenContexts: Bool,
        prioritizeThreadsCreatedAfter: Date? = nil,
        blockingManager: BlockingManager,
        transaction: DBReadTransaction
    ) -> [StoryConversationItem] {
        func sortTime(
            for associatedData: StoryContextAssociatedData?,
            thread: TSThread
        ) -> UInt64 {
            if
                let thread = thread as? TSGroupThread,
                associatedData?.lastReceivedTimestamp ?? 0 > thread.lastSentStoryTimestamp?.uint64Value ?? 0
            {
                return associatedData?.lastReceivedTimestamp ?? 0
            }

            return thread.lastSentStoryTimestamp?.uint64Value ?? 0
        }

        let threads = ThreadFinder().storyThreads(
            includeImplicitGroupThreads: includeImplicitGroupThreads,
            transaction: transaction
        )

        return buildItems(
            from: threads,
            excludeHiddenContexts: excludeHiddenContexts,
            blockingManager: blockingManager,
            transaction: transaction,
            sortingBy: { lhs, rhs in
                if (lhs.0 as? TSPrivateStoryThread)?.isMyStory == true { return true }
                if (rhs.0 as? TSPrivateStoryThread)?.isMyStory == true { return false }
                if let priorityDateThreshold = prioritizeThreadsCreatedAfter {
                    let lhsCreatedAfterThreshold = lhs.0.creationDate != nil && lhs.0.creationDate! > priorityDateThreshold
                    let rhsCreatedAfterThreshold = rhs.0.creationDate != nil && rhs.0.creationDate! > priorityDateThreshold
                    if lhsCreatedAfterThreshold != rhsCreatedAfterThreshold {
                        return lhsCreatedAfterThreshold
                    }
                }
                return sortTime(for: lhs.1, thread: lhs.0) > sortTime(for: rhs.1, thread: rhs.0)
            }
        )
    }

    public static func buildItems(
        from threads: [TSThread],
        excludeHiddenContexts: Bool,
        blockingManager: BlockingManager,
        transaction: DBReadTransaction,
        sortingBy areInIncreasingOrderFunc: (((TSThread, StoryContextAssociatedData?), (TSThread, StoryContextAssociatedData?)) -> Bool)? = nil
    ) -> [Self] {
        let outgoingStories = StoryFinder
            .outgoingStories(transaction: transaction)
            .reduce(
                into: (privateStoryThreadUniqueIDs: Set<String>(), groupIDs: Set<Data>())
            ) { partialResult, story in
                if let groupID = story.groupId {
                    partialResult.groupIDs.insert(groupID)
                    return
                }

                switch story.manifest {
                case .incoming:
                    break
                case .outgoing(recipientStates: let recipientStates):
                    partialResult.privateStoryThreadUniqueIDs.formUnion(
                        recipientStates.values.lazy
                            .flatMap(\.contexts)
                            .map(\.uuidString)
                    )
                }
            }

        var threadsAndAssociatedData = threads
            .compactMap { (thread: TSThread) -> (TSThread, StoryContextAssociatedData?)? in
                let associatedData = StoryFinder.associatedData(for: thread, transaction: transaction)
                if excludeHiddenContexts, associatedData?.isHidden ?? false {
                    return nil
                }
                return (thread, associatedData)
            }

        if let areInIncreasingOrderFunc {
            threadsAndAssociatedData.sort(by: areInIncreasingOrderFunc)
        }

        return threadsAndAssociatedData
            .compactMap { thread, associatedData -> Self? in
                let isThreadBlocked = blockingManager.isThreadBlocked(
                    thread,
                    transaction: transaction
                )

                if isThreadBlocked {
                    return nil
                }

                // Associated data tracks view state for incoming stories.
                // It does not track our own outgoing stories, so we need
                // to check that separately.
                lazy var threadHasOutgoingStories: Bool = {
                    if let groupThread = thread as? TSGroupThread {
                        if outgoingStories.groupIDs.contains(groupThread.groupId) {
                            return true
                        }
                    } else {
                        if outgoingStories.privateStoryThreadUniqueIDs.contains(thread.uniqueId) {
                            return true
                        }
                    }
                    return false
                }()

                let storyState: StoryContextViewState

                switch (associatedData?.hasUnviewedStories, associatedData?.hasUnexpiredStories) {
                case (true, _):
                    // There is an unviewed thread
                    storyState = .unviewed
                case (_, true),
                    (_, _) where threadHasOutgoingStories:
                    // There are unexpired or outgoing stories
                    storyState = .viewed
                default:
                    // There are no stories
                    storyState = .noStories
                }

                return .from(
                    thread: thread,
                    storyState: storyState,
                    isBlocked: isThreadBlocked
                )
            }
    }

    private static func from(
        thread: TSThread,
        storyState: StoryContextViewState?,
        isBlocked: Bool
    ) -> Self? {
        let backingItem: StoryConversationItem.ItemType? = {
            if let groupThread = thread as? TSGroupThread {
                guard groupThread.isLocalUserFullMember else {
                    return nil
                }
                return .groupStory(GroupConversationItem(
                    groupThreadId: groupThread.uniqueId,
                    isBlocked: isBlocked,
                    disappearingMessagesConfig: nil
                ))
            } else if let privateStoryThread = thread as? TSPrivateStoryThread {
                return .privateStory(PrivateStoryConversationItem(
                    storyThreadId: privateStoryThread.uniqueId,
                    isMyStory: privateStoryThread.isMyStory
                ))
            } else {
                owsFailDebug("Unexpected story thread type \(type(of: thread))")
                return nil
            }
        }()
        guard let backingItem = backingItem else {
            return nil
        }
        return .init(backingItem: backingItem, storyState: storyState)
    }
}

// MARK: -

extension StoryConversationItem: ConversationItem {
    public var outgoingMessageType: ConversationItemMessageType { .storyMessage }

    public var limitsVideoAttachmentLengthForStories: Bool { return true }

    public var videoAttachmentStoryLengthTooltipString: String? {
        return StoryMessage.videoSegmentationTooltip
    }

    public var messageRecipient: MessageRecipient {
        unwrapped.messageRecipient
    }

    public var isMyStory: Bool {
        switch backingItem {
        case .groupStory:
            return false
        case .privateStory(let item):
            return item.isMyStory
        }
    }

    public func title(transaction: DBReadTransaction) -> String {
        unwrapped.title(transaction: transaction)
    }

    public func subtitle(transaction: DBReadTransaction) -> String? {
        let storyRecipientStore = DependenciesBridge.shared.storyRecipientStore

        switch backingItem {
        case .privateStory(let item):
            guard let thread = item.fetchThread(tx: transaction) else {
                owsFailDebug("Unexpected thread type")
                return ""
            }
            let recipientIds: [SignalRecipient.RowId]
            do {
                recipientIds = try storyRecipientStore.fetchRecipientIds(forStoryThreadId: thread.sqliteRowId!, tx: transaction)
            } catch {
                owsFailDebug("Couldn't fetch recipientIds: \(error)")
                return ""
            }
            if item.isMyStory {
                guard StoryManager.hasSetMyStoriesPrivacy(transaction: transaction) else {
                    return OWSLocalizedString(
                        "MY_STORY_PICKER_UNSET_PRIVACY_SUBTITLE",
                        comment: "Subtitle shown on my story in the conversation picker when sending a story for the first time with unset my story privacy settings.")
                }
                switch thread.storyViewMode {
                case .blockList:
                    if recipientIds.isEmpty {
                        let format = OWSLocalizedString(
                            "MY_STORY_VIEWERS_ALL_CONNECTIONS_%d",
                            tableName: "PluralAware",
                            comment: "Format string representing the viewer count for 'My Story' when accessible to all signal connections. Embeds {{ number of viewers }}.")
                        // If we haven't added anybody to the block list, we show the total number
                        // of Signal Connections. That is *not* recipientIds; instead, it's the
                        // thread's recipient addresses, fetched here using the same method we'll
                        // use when sending a story.
                        return String.localizedStringWithFormat(format, thread.recipientAddresses(with: transaction).count)
                    } else {
                        let format = OWSLocalizedString(
                            "MY_STORY_VIEWERS_ALL_CONNECTIONS_EXCLUDING_%d",
                            tableName: "PluralAware",
                            comment: "Format string representing the excluded viewer count for 'My Story' when accessible to all signal connections. Embeds {{ number of excluded viewers }}.")
                        // If we have added somebody to the block list, we show how many people are
                        // in the exclusion list instead of the total number of Signal Connections.
                        return String.localizedStringWithFormat(format, recipientIds.count)
                    }
                case .explicit:
                    let format = OWSLocalizedString(
                        "MY_STORY_VIEWERS_ONLY_%d",
                        tableName: "PluralAware",
                        comment: "Format string representing the viewer count for 'My Story' when accessible to only an explicit list of viewers. Embeds {{ number of viewers }}.")
                    return String.localizedStringWithFormat(format, recipientIds.count)
                case .default, .disabled:
                    owsFailDebug("Unexpected view mode for my story")
                    return ""
                }
            } else {
                let format = OWSLocalizedString(
                    "PRIVATE_STORY_VIEWERS_%d",
                    tableName: "PluralAware",
                    comment: "Format string representing the viewer count for a custom story list. Embeds {{ number of viewers }}.")
                return String.localizedStringWithFormat(format, recipientIds.count)
            }
        case .groupStory:
            guard let thread = getExistingThread(transaction: transaction) else {
                owsFailDebug("Unexpectedly missing story thread")
                return nil
            }
            let format = OWSLocalizedString(
                "GROUP_STORY_VIEWERS_%d",
                tableName: "PluralAware",
                comment: "Format string representing the viewer count for a group story list. Embeds {{ number of viewers }}.")
            return String.localizedStringWithFormat(format, thread.recipientAddresses(with: transaction).count)
        }
    }

    public var image: UIImage? {
        unwrapped.image
    }

    public var isBlocked: Bool {
        unwrapped.isBlocked
    }

    public var isStory: Bool { return true }

    public var disappearingMessagesConfig: OWSDisappearingMessagesConfiguration? {
        unwrapped.disappearingMessagesConfig
    }

    public func getExistingThread(transaction: DBReadTransaction) -> TSThread? {
        unwrapped.getExistingThread(transaction: transaction)
    }

    public func getOrCreateThread(transaction: DBWriteTransaction) -> TSThread? {
        unwrapped.getOrCreateThread(transaction: transaction)
    }
}

// MARK: -

public struct PrivateStoryConversationItem {
    let storyThreadId: String
    public let isMyStory: Bool

    public func fetchThread(tx: DBReadTransaction) -> TSPrivateStoryThread? {
        return TSPrivateStoryThread.anyFetchPrivateStoryThread(uniqueId: storyThreadId, transaction: tx)
    }
}

// MARK: -

extension PrivateStoryConversationItem: ConversationItem {
    public var outgoingMessageType: ConversationItemMessageType { .storyMessage }

    public var limitsVideoAttachmentLengthForStories: Bool { return true }

    public var videoAttachmentStoryLengthTooltipString: String? {
        return StoryMessage.videoSegmentationTooltip
    }

    public var isBlocked: Bool { false }

    public var isStory: Bool { return true }

    public var disappearingMessagesConfig: OWSDisappearingMessagesConfiguration? { nil }

    public var messageRecipient: MessageRecipient { .privateStory(storyThreadId, isMyStory: isMyStory) }

    public func title(transaction: DBReadTransaction) -> String {
        guard let storyThread = getExistingThread(transaction: transaction) as? TSPrivateStoryThread else {
            owsFailDebug("Missing story thread")
            return ""
        }
        return storyThread.name
    }

    public var image: UIImage? {
        UIImage(named: "custom-story-\(Theme.isDarkThemeEnabled ? "dark" : "light")-36")
    }

    public func getExistingThread(transaction: DBReadTransaction) -> TSThread? {
        TSPrivateStoryThread.anyFetchPrivateStoryThread(uniqueId: storyThreadId, transaction: transaction)
    }

    public func getOrCreateThread(transaction: DBWriteTransaction) -> TSThread? {
        getExistingThread(transaction: transaction)
    }
}
