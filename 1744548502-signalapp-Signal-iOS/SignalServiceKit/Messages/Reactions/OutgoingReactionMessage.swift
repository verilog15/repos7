//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

extension OWSOutgoingReactionMessage {
    @objc
    func buildDataMessageReactionProto(tx: DBReadTransaction) -> SSKProtoDataMessageReaction? {
        guard let message = TSMessage.anyFetchMessage(uniqueId: messageUniqueId, transaction: tx) else {
            owsFailDebug("Missing message for reaction.")
            return nil
        }

        let reactionBuilder = SSKProtoDataMessageReaction.builder(emoji: emoji, timestamp: message.timestamp)
        reactionBuilder.setRemove(isRemoving)

        let messageAuthor: Aci?
        switch message {
        case is TSOutgoingMessage:
            messageAuthor = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: tx)?.aci
        case let message as TSIncomingMessage:
            messageAuthor = message.authorAddress.aci
        default:
            messageAuthor = nil
        }
        guard let messageAuthor else {
            owsFailDebug("Missing author for reaction.")
            return nil
        }
        reactionBuilder.setTargetAuthorAci(messageAuthor.serviceIdString)

        do {
            return try reactionBuilder.build()
        } catch {
            owsFailDebug("Couldn't build protobuf: \(error)")
            return nil
        }
    }

    public override func updateWithAllSendingRecipientsMarkedAsFailed(
        error: (any Error)? = nil,
        transaction tx: DBWriteTransaction
    ) {
        super.updateWithAllSendingRecipientsMarkedAsFailed(error: error, transaction: tx)

        revertLocalStateIfFailedForEveryone(tx: tx)
    }

    private func revertLocalStateIfFailedForEveryone(tx: DBWriteTransaction) {
        // Do nothing if we successfully delivered to anyone. Only cleanup
        // local state if we fail to deliver to anyone.
        guard sentRecipientAddresses().isEmpty else {
            Logger.warn("Failed to send reaction to some recipients")
            return
        }

        guard let localAci = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: tx)?.aci else {
            owsFailDebug("Missing localAci.")
            return
        }
        guard let message = TSMessage.anyFetchMessage(uniqueId: messageUniqueId, transaction: tx) else {
            owsFailDebug("Missing message.")
            return
        }

        Logger.error("Failed to send reaction to all recipients.")

        let currentReaction = message.reaction(for: localAci, tx: tx)

        guard currentReaction?.uniqueId == self.createdReaction?.uniqueId else {
            Logger.info("Keeping latest reaction because it's different than the failed message.")
            return
        }

        if let previousReaction {
            message.recordReaction(
                for: localAci,
                emoji: previousReaction.emoji,
                sentAtTimestamp: previousReaction.sentAtTimestamp,
                sortOrder: previousReaction.sortOrder,
                tx: tx
            )
        } else {
            message.removeReaction(for: localAci, tx: tx)
        }
    }
}
