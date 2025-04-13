//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

extension ConversationViewController {
    func setUpWallpaper() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(wallpaperDidChange),
            name: WallpaperStore.wallpaperDidChangeNotification,
            object: nil
        )
        updateWallpaperView()
    }

    @objc
    private func wallpaperDidChange(_ notification: Notification) {
        guard notification.object == nil || (notification.object as? String) == thread.uniqueId else { return }
        updateWallpaperViewBuilder()
        chatColorDidChange() // Changing the wallpaper might change the ChatColor.
    }

    func updateWallpaperViewBuilder() {
        viewState.wallpaperViewBuilder = SSKEnvironment.shared.databaseStorageRef.read { tx in Self.loadWallpaperViewBuilder(for: thread, tx: tx) }
        updateWallpaperView()
    }

    func updateWallpaperView() {
        AssertIsOnMainThread()
        backgroundContainer.set(wallpaperView: viewState.wallpaperViewBuilder?.build())
    }
}
