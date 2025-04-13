//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import AVFoundation

extension ConversationViewController {
    func addNotificationListeners() {
        AssertIsOnMainThread()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(blockListDidChange),
                                               name: BlockingManager.blockListDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(identityStateDidChange),
                                               name: .identityStateDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: .OWSApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: .OWSApplicationDidEnterBackground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: .OWSApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .OWSApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(otherUsersProfileDidChange),
                                               name: UserProfileNotifications.otherUsersProfileDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(profileWhitelistDidChange),
                                               name: UserProfileNotifications.profileWhitelistDidChange,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioSessionInterrupted),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance()
        )

        AppEnvironment.shared.callService.callServiceState.addObserver(self, syncStateImmediately: false)
    }

    @objc
    private func otherUsersProfileDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        guard
            let address = notification.userInfo?[UserProfileNotifications.profileAddressKey] as? SignalServiceAddress,
            address.isValid,
            thread.recipientAddressesWithSneakyTransaction.contains(address)
        else {
            return
        }

        if thread is TSContactThread {
            // update title with profile name
            enqueueReload()
        }

        // Reload all cells if this is a group conversation,
        // since we may need to update the sender names on the messages.
        // Use a DebounceEvent to de-bounce.
        if isGroupConversation {
            otherUsersProfileDidChangeEvent?.requestNotify()
        }
    }

    @objc
    private func profileWhitelistDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        // If profile whitelist just changed, we may want to hide a profile whitelist offer.
        if let address = notification.userInfo?[UserProfileNotifications.profileAddressKey] as? SignalServiceAddress,
           address.isValid,
           thread.recipientAddressesWithSneakyTransaction.contains(address) {
            ensureBannerState()
            showMessageRequestDialogIfRequired()
        } else if let groupId = notification.userInfo?[UserProfileNotifications.profileGroupIdKey] as? Data,
                  !groupId.isEmpty,
                  let groupThread = thread as? TSGroupThread,
                  groupThread.groupModel.groupId == groupId {
            ensureBannerState()
            showMessageRequestDialogIfRequired()
        }
    }

    @objc
    private func blockListDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        ensureBannerState()
    }

    @objc
    private func identityStateDidChange(_ notification: NSNotification) {
        AssertIsOnMainThread()

        enqueueReload()
        ensureBannerState()
    }

    @objc
    private func applicationWillEnterForeground(_ notification: NSNotification) {
        AssertIsOnMainThread()

        startReadTimer()
        updateCellsVisible()
    }

    @objc
    private func applicationDidEnterBackground(_ notification: NSNotification) {
        AssertIsOnMainThread()

        updateCellsVisible()
        mediaCache.removeAllObjects()
        cancelReadTimer()
    }

    @objc
    private func applicationWillResignActive(_ notification: NSNotification) {
        AssertIsOnMainThread()

        finishRecordingVoiceMessage(sendImmediately: false)
        self.isUserScrolling = false
        self.isWaitingForDeceleration = false
        saveDraft()
        markVisibleMessagesAsRead()
        mediaCache.removeAllObjects()
        cancelReadTimer()
        dismissPresentedViewControllerIfNecessary()
        saveLastVisibleSortIdAndOnScreenPercentage()

        self.dismissKeyBoard()
    }

    @objc
    private func applicationDidBecomeActive(_ notification: NSNotification) {
        AssertIsOnMainThread()

        startReadTimer()
    }

    @objc
    private func audioSessionInterrupted(_ notification: Notification) {
        AssertIsOnMainThread()

        finishRecordingVoiceMessage(sendImmediately: false)
    }
}

// MARK: -

extension ConversationViewController: CallServiceStateObserver {
    func didUpdateCall(from oldValue: SignalCall?, to newValue: SignalCall?) {
        AssertIsOnMainThread()
        updateBarButtonItems()
    }
}
