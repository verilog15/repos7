//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

protocol ThreadSwipeHandler {
    func updateUIAfterSwipeAction()
}

extension ThreadSwipeHandler where Self: UIViewController {

    func leadingSwipeActionsConfiguration(for threadViewModel: ThreadViewModel?) -> UISwipeActionsConfiguration? {
        AssertIsOnMainThread()

        guard let threadViewModel = threadViewModel else {
            return nil
        }

        let isThreadPinned = threadViewModel.isPinned
        let pinnedStateAction: UIContextualAction
        if isThreadPinned {
            pinnedStateAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
                self?.unpinThread(threadViewModel: threadViewModel)
                completion(false)
            }
            pinnedStateAction.backgroundColor = UIColor(rgbHex: 0xff990a)
            pinnedStateAction.accessibilityLabel = CommonStrings.unpinAction
            pinnedStateAction.image = actionImage(name: "pin-slash-fill", title: CommonStrings.unpinAction)
        } else {
            pinnedStateAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
                self?.pinThread(threadViewModel: threadViewModel)
                completion(false)
            }
            pinnedStateAction.backgroundColor = UIColor(rgbHex: 0xff990a)
            pinnedStateAction.accessibilityLabel = CommonStrings.pinAction
            pinnedStateAction.image = actionImage(name: "pin-fill", title: CommonStrings.pinAction)
        }

        let readStateAction: UIContextualAction
        if threadViewModel.hasUnreadMessages {
            readStateAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
                completion(false)
                self?.markThreadAsRead(threadViewModel: threadViewModel)
            }
            readStateAction.backgroundColor = .ows_accentBlue
            readStateAction.accessibilityLabel = CommonStrings.readAction
            readStateAction.image = actionImage(name: "chat-check-fill", title: CommonStrings.readAction)
        } else {
            readStateAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
                completion(false)
                self?.markThreadAsUnread(threadViewModel: threadViewModel)
            }
            readStateAction.backgroundColor = .ows_accentBlue
            readStateAction.accessibilityLabel = CommonStrings.unreadAction
            readStateAction.image = actionImage(name: "chat-badge-fill", title: CommonStrings.unreadAction)
        }

        // The first action will be auto-performed for "very long swipes".
        return UISwipeActionsConfiguration(actions: [ readStateAction, pinnedStateAction ])
    }

    func trailingSwipeActionsConfiguration(for threadViewModel: ThreadViewModel?, closeConversationBlock: (() -> Void)? = nil) -> UISwipeActionsConfiguration? {
        AssertIsOnMainThread()

        guard let threadViewModel = threadViewModel else {
            return nil
        }

        let muteAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            if threadViewModel.isMuted {
                self?.unmuteThread(threadViewModel: threadViewModel)
            } else {
                self?.muteThreadWithSelection(threadViewModel: threadViewModel)
            }
            completion(false)
        }
        muteAction.backgroundColor = .ows_accentIndigo
        muteAction.image = actionImage(
            name: threadViewModel.isMuted ? "bell-fill" : "bell-slash-fill",
            title: threadViewModel.isMuted ? CommonStrings.unmuteButton : CommonStrings.muteButton
        )
        muteAction.accessibilityLabel = threadViewModel.isMuted ? CommonStrings.unmuteButton : CommonStrings.muteButton

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let self else {
                completion(false)
                return
            }

            DeleteForMeInfoSheetCoordinator.fromGlobals().coordinateDelete(
                fromViewController: self
            ) { [weak self] _, threadSoftDeleteManager in
                guard let self else { return }

                self.deleteThreadWithConfirmation(
                    threadViewModel: threadViewModel,
                    threadSoftDeleteManager: threadSoftDeleteManager,
                    closeConversationBlock: closeConversationBlock
                )
                completion(false)
            }
        }
        deleteAction.backgroundColor = .ows_accentRed
        deleteAction.image = actionImage(name: "trash-fill", title: CommonStrings.deleteButton)
        deleteAction.accessibilityLabel = CommonStrings.deleteButton

        let archiveAction = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, completion) in
            self?.archiveThread(threadViewModel: threadViewModel, closeConversationBlock: closeConversationBlock)
            completion(false)
        }

        let archiveTitle = threadViewModel.isArchived ? CommonStrings.unarchiveAction : CommonStrings.archiveAction
        let iconName = threadViewModel.isArchived ? "archive-up-fill" : "archive-fill"
        archiveAction.backgroundColor = Theme.isDarkThemeEnabled ? .ows_gray45 : .ows_gray25
        archiveAction.image = actionImage(name: iconName, title: archiveTitle)
        archiveAction.accessibilityLabel = archiveTitle

        // The first action will be auto-performed for "very long swipes".
        return UISwipeActionsConfiguration(actions: [archiveAction, deleteAction, muteAction])
    }

    func actionImage(name imageName: String, title: String) -> UIImage? {
        AssertIsOnMainThread()
        // We need to bake the title text into the image because `UIContextualAction`
        // only displays title + image when the cell's height > 91. We want to always
        // show both.
        guard let image = UIImage(named: imageName) else {
            owsFailDebug("Missing image.")
            return nil
        }
        guard let image = image.withTitle(title,
                                          font: UIFont.systemFont(ofSize: 13),
                                          color: .ows_white,
                                          maxTitleWidth: 68,
                                          minimumScaleFactor: CGFloat(8) / CGFloat(13),
                                          spacing: 4) else {
            owsFailDebug("Missing image.")
            return nil
        }
        return image.withRenderingMode(.alwaysTemplate)
    }

    func archiveThread(threadViewModel: ThreadViewModel, closeConversationBlock: (() -> Void)?) {
        AssertIsOnMainThread()

        closeConversationBlock?()
        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            threadViewModel.associatedData.updateWith(isArchived: !threadViewModel.isArchived,
                                                      updateStorageService: true,
                                                      transaction: transaction)
        }
        updateUIAfterSwipeAction()
    }

    fileprivate func deleteThreadWithConfirmation(
        threadViewModel: ThreadViewModel,
        threadSoftDeleteManager: any ThreadSoftDeleteManager,
        closeConversationBlock: (() -> Void)?
    ) {
        AssertIsOnMainThread()

        let alert = ActionSheetController(title: OWSLocalizedString("CONVERSATION_DELETE_CONFIRMATION_ALERT_TITLE",
                                                                   comment: "Title for the 'conversation delete confirmation' alert."),
                                          message: OWSLocalizedString("CONVERSATION_DELETE_CONFIRMATION_ALERT_MESSAGE",
                                                                     comment: "Message for the 'conversation delete confirmation' alert."))
        alert.addAction(ActionSheetAction(
            title: CommonStrings.deleteButton,
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }

            closeConversationBlock?()

            ModalActivityIndicatorViewController.present(
                fromViewController: self
            ) { [weak self] modal in
                guard let self else { return }

                await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { tx in
                    threadSoftDeleteManager.softDelete(
                        threads: [threadViewModel.threadRecord],
                        sendDeleteForMeSyncMessage: true,
                        tx: tx
                    )
                }

                modal.dismiss {
                    self.updateUIAfterSwipeAction()
                }
            }
        })
        alert.addAction(OWSActionSheets.cancelAction)

        presentActionSheet(alert)
    }

    func markThreadAsRead(threadViewModel: ThreadViewModel) {
        AssertIsOnMainThread()

        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            threadViewModel.threadRecord.markAllAsRead(updateStorageService: true, transaction: transaction)
        }
    }

    fileprivate func markThreadAsUnread(threadViewModel: ThreadViewModel) {
        AssertIsOnMainThread()

        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            threadViewModel.associatedData.updateWith(isMarkedUnread: true, updateStorageService: true, transaction: transaction)
        }
    }

    fileprivate func muteThreadWithSelection(threadViewModel: ThreadViewModel) {
        AssertIsOnMainThread()

        let alert = ActionSheetController(title: OWSLocalizedString("CONVERSATION_MUTE_CONFIRMATION_ALERT_TITLE",
                                                                   comment: "Title for the 'conversation mute confirmation' alert."))
        for (title, seconds) in [
            (OWSLocalizedString("CONVERSATION_MUTE_CONFIRMATION_OPTION_1H", comment: "1 hour"), TimeInterval.hour),
            (OWSLocalizedString("CONVERSATION_MUTE_CONFIRMATION_OPTION_8H", comment: "8 hours"), 8 * TimeInterval.hour),
            (OWSLocalizedString("CONVERSATION_MUTE_CONFIRMATION_OPTION_1D", comment: "1 day"), TimeInterval.day),
            (OWSLocalizedString("CONVERSATION_MUTE_CONFIRMATION_OPTION_1W", comment: "1 week"), TimeInterval.week),
            (OWSLocalizedString("CONVERSATION_MUTE_CONFIRMATION_OPTION_ALWAYS", comment: "Always"), -1)] {
            alert.addAction(ActionSheetAction(title: title, style: .default) { [weak self] _ in
                self?.muteThread(threadViewModel: threadViewModel, duration: seconds)
            })
        }
        alert.addAction(OWSActionSheets.cancelAction)

        presentActionSheet(alert)
    }

    fileprivate func muteThread(threadViewModel: ThreadViewModel, duration seconds: TimeInterval) {
        AssertIsOnMainThread()

        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            let timestamp = seconds < 0
            ? ThreadAssociatedData.alwaysMutedTimestamp
            : (seconds == 0 ? 0 : Date.ows_millisecondTimestamp() + UInt64(seconds * 1000))
            threadViewModel.associatedData.updateWith(mutedUntilTimestamp: timestamp, updateStorageService: true, transaction: transaction)
        }
    }

    fileprivate func unmuteThread(threadViewModel: ThreadViewModel) {
        AssertIsOnMainThread()

        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            threadViewModel.associatedData.updateWith(mutedUntilTimestamp: 0, updateStorageService: true, transaction: transaction)
        }
    }

    fileprivate func pinThread(threadViewModel: ThreadViewModel) {
        AssertIsOnMainThread()

        do {
            try SSKEnvironment.shared.databaseStorageRef.write { transaction in
                try DependenciesBridge.shared.pinnedThreadManager.pinThread(
                    threadViewModel.threadRecord,
                    updateStorageService: true,
                    tx: transaction
                )
            }
        } catch {
            if case PinnedThreadError.tooManyPinnedThreads = error {
                OWSActionSheets.showActionSheet(title: OWSLocalizedString("PINNED_CONVERSATION_LIMIT",
                                                                         comment: "An explanation that you have already pinned the maximum number of conversations."))
            } else {
                owsFailDebug("Error: \(error)")
            }
        }
    }

    fileprivate func unpinThread(threadViewModel: ThreadViewModel) {
        AssertIsOnMainThread()

        do {
            try SSKEnvironment.shared.databaseStorageRef.write { transaction in
                try DependenciesBridge.shared.pinnedThreadManager.unpinThread(
                    threadViewModel.threadRecord,
                    updateStorageService: true,
                    tx: transaction
                )
            }
        } catch {
            owsFailDebug("Error: \(error)")
        }
    }

}
