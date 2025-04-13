//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

public import SignalServiceKit
import SignalUI

struct StoryViewModel {
    let context: StoryContext

    let messages: [StoryMessage]
    let hasUnviewedMessages: Bool

    // NOTE: "hidden" stories are still shown,
    // just in a separate section thats collapsed by default.
    let isHidden: Bool

    let latestMessage: StoryMessage
    let latestMessageAttachment: StoryThumbnailView.Attachment
    let hasReplies: Bool
    let latestMessageName: String
    let latestMessageIdentifier: InteractionSnapshotIdentifier
    let latestMessageTimestamp: UInt64
    let latestMessageViewedTimestamp: UInt64?
    let latestMessageSendingState: TSOutgoingMessageState

    let latestMessageAvatarDataSource: ConversationAvatarDataSource

    var isSystemStory: Bool {
        return messages.first?.authorAddress.isSystemStoryAddress ?? false
    }

    init(
        messages: [StoryMessage],
        isHidden: Bool? = nil,
        transaction: DBReadTransaction
    ) throws {
        let sortedFilteredMessages = messages.lazy.sorted { $0.timestamp < $1.timestamp }
        self.messages = sortedFilteredMessages
        self.hasUnviewedMessages = sortedFilteredMessages.contains { $0.localUserViewedTimestamp == nil }

        guard let latestMessage = sortedFilteredMessages.last else {
            throw OWSAssertionError("At least one message is required.")
        }

        self.latestMessage = latestMessage
        self.context = latestMessage.context
        self.hasReplies = sortedFilteredMessages.contains(where: \.hasReplies)

        latestMessageName = StoryUtil.authorDisplayName(
            for: latestMessage,
            contactsManager: SSKEnvironment.shared.contactManagerRef,
            transaction: transaction
        )
        latestMessageAvatarDataSource = try StoryUtil.contextAvatarDataSource(for: latestMessage, transaction: transaction)
        latestMessageAttachment = .from(latestMessage, transaction: transaction)
        latestMessageIdentifier = .fromStoryMessage(latestMessage)
        latestMessageTimestamp = latestMessage.timestamp
        latestMessageViewedTimestamp = latestMessage.localUserViewedTimestamp
        latestMessageSendingState = latestMessage.sendingState

        self.isHidden = isHidden ?? context.isHidden(transaction: transaction)
    }

    /// Returns nil if there are no messages left after deletions are applied.
    /// Throws if databae lookups fail.
    func copy(
        updatedMessages: [StoryMessage],
        deletedMessageRowIds: [Int64],
        isHidden: Bool,
        transaction: DBReadTransaction
    ) throws -> Self? {
        var newMessages = updatedMessages
        var messages: [StoryMessage] = self.messages.lazy
            .filter { oldMessage in
                guard let oldMessageId = oldMessage.id else { return true }
                return !deletedMessageRowIds.contains(oldMessageId)
            }
            .map { oldMessage in
                if let idx = newMessages.firstIndex(where: { $0.uniqueId == oldMessage.uniqueId }) {
                    return newMessages.remove(at: idx)
                } else {
                    return oldMessage
                }
            }
        messages.append(contentsOf: newMessages)
        guard !messages.isEmpty else { return nil }
        return try .init(messages: messages, isHidden: isHidden, transaction: transaction)
    }
}

extension StoryContext: BatchUpdateValue {
    public var batchUpdateId: String {
        switch self {
        case .groupId(let data):
            return data.hexadecimalString
        case .authorAci(let authorAci):
            return authorAci.serviceIdUppercaseString
        case .privateStory(let uniqueId):
            return uniqueId
        case .none:
            owsFailDebug("Unexpected StoryContext for batch update")
            return "none"
        }
    }
}
