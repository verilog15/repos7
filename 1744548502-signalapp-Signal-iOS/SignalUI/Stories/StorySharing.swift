//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

public import SignalServiceKit

public enum StorySharing {
    public static func sendTextStory(
        with messageBody: MessageBody,
        linkPreviewDraft: OWSLinkPreviewDraft?,
        to conversations: [ConversationItem]
    ) -> AttachmentMultisend.Result? {
        let storyConversations = conversations.filter { $0.outgoingMessageType == .storyMessage }
        owsAssertDebug(conversations.count == storyConversations.count)

        guard !storyConversations.isEmpty else { return nil }

        return AttachmentMultisend.sendTextAttachment(
            buildTextAttachment(with: messageBody, linkPreviewDraft: linkPreviewDraft),
            to: storyConversations
        )
    }

    private static func buildTextAttachment(
        with messageBody: MessageBody,
        linkPreviewDraft: OWSLinkPreviewDraft?
    ) -> UnsentTextAttachment {
        // Send the text message to any selected story recipients
        // as a text story with default styling.
        return UnsentTextAttachment(
            body: text(for: messageBody, with: linkPreviewDraft),
            textStyle: .regular,
            textForegroundColor: .white,
            textBackgroundColor: nil,
            background: .color(.init(rgbHex: 0x688BD4)),
            linkPreviewDraft: linkPreviewDraft
        )
    }

    internal static func text(for messageBody: MessageBody, with linkPreview: OWSLinkPreviewDraft?) -> StyleOnlyMessageBody? {
        // Hydrate any mentions in the message body but preserve styles.
        let hydratedBody = SSKEnvironment.shared.databaseStorageRef.read {
            return messageBody
                .hydrating(
                    mentionHydrator: ContactsMentionHydrator.mentionHydrator(transaction: $0)
                )
                .asStyleOnlyBody()
        }

        let finalBody: StyleOnlyMessageBody?
        if let linkPreviewUrlString = linkPreview?.urlString, hydratedBody.text.contains(linkPreviewUrlString) {
            if hydratedBody.text == linkPreviewUrlString {
                // If the only message text is the URL of the link preview, omit the message text
                finalBody = nil
            } else if
                hydratedBody.text.hasPrefix(linkPreviewUrlString),
                CharacterSet.whitespacesAndNewlines.contains(
                    hydratedBody.text[hydratedBody.text.index(
                        hydratedBody.text.startIndex,
                        offsetBy: linkPreviewUrlString.count
                    )]
                )
            {
                // If the URL is at the start of the message, strip it off
                finalBody = hydratedBody.stripAndDropFirst((linkPreviewUrlString as NSString).length)
            } else if
                hydratedBody.text.hasSuffix(linkPreviewUrlString),
                CharacterSet.whitespacesAndNewlines.contains(
                    hydratedBody.text[hydratedBody.text.index(
                        hydratedBody.text.endIndex,
                        offsetBy: -(linkPreviewUrlString.count + 1)
                    )]
                )
            {
                // If the URL is at the end of the message, strip it off
                finalBody = hydratedBody.stripAndDropLast((linkPreviewUrlString as NSString).length)
            } else {
                // If the URL is in the middle of the message, send the message as is
                finalBody = hydratedBody
            }
        } else {
            finalBody = hydratedBody
        }
        return finalBody
    }
}

private extension CharacterSet {
    func contains(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy(contains(_:))
    }
}
