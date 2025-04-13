//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

public extension MessageBackup {

    /// An identifier for a ``BackupProto_ChatItem`` backup frame.
    struct ChatItemId: MessageBackupLoggableId, Hashable {
        let value: UInt64

        public init(backupProtoChatItem: BackupProto_ChatItem) {
            self.value = backupProtoChatItem.dateSent
        }

        public init(interaction: TSInteraction) {
            self.value = interaction.timestamp
        }

        // MARK: MessageBackupLoggableId

        public var typeLogString: String { "BackupProto_ChatItem" }
        public var idLogString: String { "timestamp: \(value)" }
    }
}

// MARK: -

public class MessageBackupChatItemArchiver: MessageBackupProtoArchiver {
    typealias ChatItemId = MessageBackup.ChatItemId
    typealias ArchiveMultiFrameResult = MessageBackup.ArchiveMultiFrameResult<MessageBackup.InteractionUniqueId>
    typealias RestoreFrameResult = MessageBackup.RestoreFrameResult<ChatItemId>

    private typealias ArchiveFrameError = MessageBackup.ArchiveFrameError<MessageBackup.InteractionUniqueId>

    private let attachmentManager: AttachmentManager
    private let attachmentStore: AttachmentStore
    private let backupAttachmentDownloadManager: BackupAttachmentDownloadManager
    private let callRecordStore: CallRecordStore
    private let contactManager: MessageBackup.Shims.ContactManager
    private let editMessageStore: EditMessageStore
    private let groupCallRecordManager: GroupCallRecordManager
    private let groupUpdateItemBuilder: GroupUpdateItemBuilder
    private let individualCallRecordManager: IndividualCallRecordManager
    private let interactionStore: MessageBackupInteractionStore
    private let archivedPaymentStore: ArchivedPaymentStore
    private let reactionStore: ReactionStore
    private let threadStore: MessageBackupThreadStore

    private lazy var attachmentsArchiver = MessageBackupMessageAttachmentArchiver(
        attachmentManager: attachmentManager,
        attachmentStore: attachmentStore,
        backupAttachmentDownloadManager: backupAttachmentDownloadManager
    )
    private lazy var reactionArchiver = MessageBackupReactionArchiver(
        reactionStore: MessageBackupReactionStore()
    )
    private lazy var contentsArchiver = MessageBackupTSMessageContentsArchiver(
        interactionStore: interactionStore,
        archivedPaymentStore: archivedPaymentStore,
        attachmentsArchiver: attachmentsArchiver,
        reactionArchiver: reactionArchiver
    )
    private lazy var incomingMessageArchiver = MessageBackupTSIncomingMessageArchiver(
        contentsArchiver: contentsArchiver,
        editMessageStore: editMessageStore,
        interactionStore: interactionStore
    )
    private lazy var outgoingMessageArchiver = MessageBackupTSOutgoingMessageArchiver(
        contentsArchiver: contentsArchiver,
        editMessageStore: editMessageStore,
        interactionStore: interactionStore
    )
    private lazy var chatUpdateMessageArchiver = MessageBackupChatUpdateMessageArchiver(
        callRecordStore: callRecordStore,
        contactManager: contactManager,
        groupCallRecordManager: groupCallRecordManager,
        groupUpdateItemBuilder: groupUpdateItemBuilder,
        individualCallRecordManager: individualCallRecordManager,
        interactionStore: interactionStore
    )

    public init(
        attachmentManager: AttachmentManager,
        attachmentStore: AttachmentStore,
        backupAttachmentDownloadManager: BackupAttachmentDownloadManager,
        callRecordStore: CallRecordStore,
        contactManager: MessageBackup.Shims.ContactManager,
        editMessageStore: EditMessageStore,
        groupCallRecordManager: GroupCallRecordManager,
        groupUpdateItemBuilder: GroupUpdateItemBuilder,
        individualCallRecordManager: IndividualCallRecordManager,
        interactionStore: MessageBackupInteractionStore,
        archivedPaymentStore: ArchivedPaymentStore,
        reactionStore: ReactionStore,
        threadStore: MessageBackupThreadStore
    ) {
        self.attachmentManager = attachmentManager
        self.attachmentStore = attachmentStore
        self.backupAttachmentDownloadManager = backupAttachmentDownloadManager
        self.callRecordStore = callRecordStore
        self.contactManager = contactManager
        self.editMessageStore = editMessageStore
        self.groupCallRecordManager = groupCallRecordManager
        self.groupUpdateItemBuilder = groupUpdateItemBuilder
        self.individualCallRecordManager = individualCallRecordManager
        self.interactionStore = interactionStore
        self.archivedPaymentStore = archivedPaymentStore
        self.reactionStore = reactionStore
        self.threadStore = threadStore
    }

    // MARK: -

    /// Archive all ``TSInteraction``s (they map to ``BackupProto_ChatItem`` and ``BackupProto_Call``).
    ///
    /// - Returns: ``ArchiveMultiFrameResult.success`` if all frames were written without error, or either
    /// partial or complete failure otherwise.
    /// How to handle ``ArchiveMultiFrameResult.partialSuccess`` is up to the caller,
    /// but typically an error will be shown to the user, but the backup will be allowed to proceed.
    /// ``ArchiveMultiFrameResult.completeFailure``, on the other hand, will stop the entire backup,
    /// and should be used if some critical or category-wide failure occurs.
    func archiveInteractions(
        stream: MessageBackupProtoOutputStream,
        context: MessageBackup.ChatArchivingContext
    ) throws(CancellationError) -> ArchiveMultiFrameResult {
        var completeFailureError: MessageBackup.FatalArchivingError?
        var partialFailures = [ArchiveFrameError]()

        func archiveInteraction(
            _ interaction: TSInteraction,
            _ frameBencher: MessageBackup.Bencher.FrameBencher
        ) -> Bool {
            var stop = false
            autoreleasepool {
                let result = self.archiveInteraction(
                    interaction,
                    stream: stream,
                    frameBencher: frameBencher,
                    context: context
                )
                switch result {
                case .success:
                    break
                case .partialSuccess(let errors):
                    partialFailures.append(contentsOf: errors)
                case .completeFailure(let error):
                    completeFailureError = error
                    stop = true
                    return
                }
            }

            return !stop
        }

        do {
            try context.bencher.wrapEnumeration(
                interactionStore.enumerateAllInteractions(tx:block:),
                tx: context.tx
            ) { interaction, frameBencher in
                try Task.checkCancellation()
                return archiveInteraction(interaction, frameBencher)
            }
        } catch let error as CancellationError {
            throw error
        } catch let error {
            // Errors thrown here are from the iterator's SQL query,
            // not the individual interaction handler.
            return .completeFailure(.fatalArchiveError(.interactionIteratorError(error)))
        }

        if let completeFailureError {
            return .completeFailure(completeFailureError)
        } else if partialFailures.isEmpty {
            return .success
        } else {
            return .partialSuccess(partialFailures)
        }
    }

    private func archiveInteraction(
        _ interaction: TSInteraction,
        stream: MessageBackupProtoOutputStream,
        frameBencher: MessageBackup.Bencher.FrameBencher,
        context: MessageBackup.ChatArchivingContext
    ) -> ArchiveMultiFrameResult {
        var partialErrors = [ArchiveFrameError]()

        let chatId = context[interaction.uniqueThreadIdentifier]
        let threadInfo = chatId.map { context[$0] } ?? nil

        if context.gv1ThreadIds.contains(interaction.uniqueThreadIdentifier) {
            /// We are knowingly dropping GV1 data from backups, so we'll skip
            /// archiving any interactions for GV1 threads without errors.
            return .success
        }

        guard let chatId, let threadInfo else {
            partialErrors.append(.archiveFrameError(
                .referencedThreadIdMissing(interaction.uniqueThreadIdentifier),
                interaction.uniqueInteractionId
            ))
            return .partialSuccess(partialErrors)
        }

        let archiveInteractionResult: MessageBackup.ArchiveInteractionResult<MessageBackup.InteractionArchiveDetails>
        if
            let message = interaction as? TSMessage,
            message.isGroupStoryReply
        {
            // We skip group story reply messages, as stories
            // aren't backed up so neither should their replies.
            return .success
        } else if let incomingMessage = interaction as? TSIncomingMessage {
            archiveInteractionResult = incomingMessageArchiver.archiveIncomingMessage(
                incomingMessage,
                threadInfo: threadInfo,
                context: context
            )
        } else if let outgoingMessage = interaction as? TSOutgoingMessage {
            archiveInteractionResult = outgoingMessageArchiver.archiveOutgoingMessage(
                outgoingMessage,
                threadInfo: threadInfo,
                context: context
            )
        } else if let individualCallInteraction = interaction as? TSCall {
            archiveInteractionResult = chatUpdateMessageArchiver.archiveIndividualCall(
                individualCallInteraction,
                threadInfo: threadInfo,
                context: context
            )
        } else if let groupCallInteraction = interaction as? OWSGroupCallMessage {
            archiveInteractionResult = chatUpdateMessageArchiver.archiveGroupCall(
                groupCallInteraction,
                threadInfo: threadInfo,
                context: context
            )
        } else if let errorMessage = interaction as? TSErrorMessage {
            archiveInteractionResult = chatUpdateMessageArchiver.archiveErrorMessage(
                errorMessage,
                threadInfo: threadInfo,
                context: context
            )
        } else if let infoMessage = interaction as? TSInfoMessage {
            archiveInteractionResult = chatUpdateMessageArchiver.archiveInfoMessage(
                infoMessage,
                threadInfo: threadInfo,
                context: context
            )
        } else {
            /// Any interactions that landed us here will be legacy messages we
            /// no longer support and which have no corresponding type in the
            /// Backup, so we'll skip them and report it as a success.
            return .success
        }

        var details: MessageBackup.InteractionArchiveDetails
        switch archiveInteractionResult {
        case .success(let deets):
            details = deets
        case .partialFailure(let deets, let errors):
            details = deets
            partialErrors.append(contentsOf: errors)
        case .skippableInteraction:
            // Skip! Say it succeeded so we ignore it.
            return .success
        case .messageFailure(let errors):
            partialErrors.append(contentsOf: errors)
            return .partialSuccess(partialErrors)
        case .completeFailure(let error):
            return .completeFailure(error)
        }

        // We may skip archiving messages based on their expiration
        // (disappearing message) details.
        if shouldSkipMessageBasedOnExpiration(
            details: details,
            context: context
        ) {
            // Skip, but treat as a success.
            return .success
        }

        // A bug on iOS allowed us to create edits of voice notes that contained
        // text as well, which are not allowed in a Backup. Sanitize before
        // writing that disallowed content to the stream.
        sanitizeVoiceNotesWithText(details: &details)

        let error = Self.writeFrameToStream(
            stream,
            objectId: interaction.uniqueInteractionId,
            frameBencher: frameBencher
        ) {
            let chatItem = buildChatItem(
                fromDetails: details,
                chatId: chatId
            )

            var frame = BackupProto_Frame()
            frame.item = .chatItem(chatItem)
            return frame
        }

        if let error {
            partialErrors.append(error)
            return .partialSuccess(partialErrors)
        } else if partialErrors.isEmpty {
            return .success
        } else {
            return .partialSuccess(partialErrors)
        }
    }

    /// Strips the "voice message" flag from the attachments of all revisions
    /// of the given message, if any of those revisions include both a voice
    /// message and text.
    ///
    /// This works around an issue in which iOS allowed editing of voice
    /// messages such that they could get body text added, by converting those
    /// messages to "text messages with a non-voice-message audio attachment".
    private func sanitizeVoiceNotesWithText(
        details: inout MessageBackup.InteractionArchiveDetails
    ) {
        let anyRevisionContainsVoiceNoteAndText = details.anyRevisionContainsChatItemType { chatItemType -> Bool in
            switch chatItemType {
            case .standardMessage(let standardMessageProto):
                let hasText = standardMessageProto.hasText
                let hasVoiceNote = standardMessageProto.attachments.contains {
                    $0.flag == .voiceMessage
                }

                return hasText && hasVoiceNote
            default:
                return false
            }
        }

        guard anyRevisionContainsVoiceNoteAndText else { return }

        details.mutateChatItemTypes { _chatItemType -> MessageBackup.InteractionArchiveDetails.ChatItemType in
            switch _chatItemType {
            case .standardMessage(var standardMessageProto):
                standardMessageProto.attachments = standardMessageProto.attachments.map { attachment in
                    if attachment.flag == .voiceMessage {
                        var _attachment = attachment
                        _attachment.flag = .none
                        return _attachment
                    }

                    return attachment
                }

                return .standardMessage(standardMessageProto)
            default:
                return _chatItemType
            }
        }
    }

    private func shouldSkipMessageBasedOnExpiration(
        details: MessageBackup.InteractionArchiveDetails,
        context: MessageBackup.ArchivingContext
    ) -> Bool {
        guard
            let expiresInMs = details.expiresInMs,
            expiresInMs > 0
        else {
            // If the message isn't expiring, no reason to skip.
            return false
        }

        if expiresInMs <= context.includedContentFilter.minExpirationTimeMs {
            // If the expire timer was less than our minimum, we can always
            // skip.
            return true
        } else if let expireStartDate = details.expireStartDate {
            // If the expiration timer has started, check whether the
            // remaining time before it expires is sufficient.
            let expirationDate = expireStartDate + expiresInMs
            let minExpirationDate = context.startTimestampMs + context.includedContentFilter.minRemainingTimeUntilExpirationMs

            return expirationDate <= minExpirationDate
        } else {
            return false
        }
    }

    private func buildChatItem(
        fromDetails details: MessageBackup.InteractionArchiveDetails,
        chatId: MessageBackup.ChatId
    ) -> BackupProto_ChatItem {
        var chatItem = BackupProto_ChatItem()
        chatItem.chatID = chatId.value
        chatItem.authorID = details.author.value
        chatItem.dateSent = details.dateCreated
        if let expiresInMs = details.expiresInMs, expiresInMs > 0 {
            if let expireStartDate = details.expireStartDate {
                chatItem.expireStartDate = expireStartDate
            }
            chatItem.expiresInMs = expiresInMs
        }
        chatItem.sms = details.isSmsPreviouslyRestoredFromBackup
        chatItem.item = details.chatItemType
        chatItem.directionalDetails = details.directionalDetails
        chatItem.revisions = details.pastRevisions.map { pastRevisionDetails in
            /// Recursively map our past revision details to `ChatItem`s of
            /// their own. (Their `pastRevisions` will all be empty.)
            return buildChatItem(
                fromDetails: pastRevisionDetails,
                chatId: chatId
            )
        }

        return chatItem
    }

    // MARK: -

    /// Restore a single ``BackupProto_ChatItem`` frame.
    ///
    /// - Returns: ``RestoreFrameResult.success`` if all frames were read without error.
    /// How to handle ``RestoreFrameResult.failure`` is up to the caller,
    /// but typically an error will be shown to the user, but the restore will be allowed to proceed.
    func restore(
        _ chatItem: BackupProto_ChatItem,
        context: MessageBackup.ChatItemRestoringContext
    ) -> RestoreFrameResult {
        func restoreFrameError(
            _ error: MessageBackup.RestoreFrameError<MessageBackup.ChatItemId>.ErrorType,
            line: UInt = #line
        ) -> RestoreFrameResult {
            return .failure([.restoreFrameError(error, chatItem.id, line: line)])
        }

        switch context.recipientContext[chatItem.authorRecipientId] {
        case .releaseNotesChannel:
            // The release notes channel doesn't exist yet, so for the time
            // being we'll drop all chat items destined for it.
            //
            // TODO: [Backups] Implement restoring chat items into the release notes channel chat.
            return .success
        default:
            break
        }

        guard let thread = context.chatContext[chatItem.typedChatId] else {
            return restoreFrameError(.invalidProtoData(.chatIdNotFound(chatItem.typedChatId)))
        }

        let restoreInteractionResult: MessageBackup.RestoreInteractionResult<Void>
        switch chatItem.directionalDetails {
        case nil:
            return .unrecognizedEnum(MessageBackup.UnrecognizedEnumError(
                enumType: BackupProto_ChatItem.OneOf_DirectionalDetails.self
            ))
        case .incoming:
            restoreInteractionResult = incomingMessageArchiver.restoreIncomingChatItem(
                chatItem,
                chatThread: thread,
                context: context
            )
        case .outgoing:
            restoreInteractionResult = outgoingMessageArchiver.restoreChatItem(
                chatItem,
                chatThread: thread,
                context: context
            )
        case .directionless:
            switch chatItem.item {
            case nil:
                return .unrecognizedEnum(MessageBackup.UnrecognizedEnumError(
                    enumType: BackupProto_ChatItem.OneOf_Item.self
                ))
            case
                    .standardMessage,
                    .contactMessage,
                    .giftBadge,
                    .viewOnceMessage,
                    .paymentNotification,
                    .remoteDeletedMessage,
                    .stickerMessage,
                    .directStoryReplyMessage:
                return restoreFrameError(.invalidProtoData(.directionlessChatItemNotUpdateMessage))
            case .updateMessage:
                restoreInteractionResult = chatUpdateMessageArchiver.restoreChatItem(
                    chatItem,
                    chatThread: thread,
                    context: context
                )
            }
        }

        switch restoreInteractionResult {
        case .success:
            return .success
        case .unrecognizedEnum(let error):
            return .unrecognizedEnum(error)
        case .partialRestore(_, let errors):
            return .partialRestore(errors)
        case .messageFailure(let errors):
            return .failure(errors)
        }
    }
}
