//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/// Backup info provided by the server that is cached locally, so this can be discarded and
/// refreshed at any time.
/// 
/// `cdn`, `backupDir`, and `mediaDir` should be static as long as backup state doesn't
/// significantly change (e.g. - changing subscription level, re-enabling backups after the grace period)
public struct MessageBackupRemoteInfo: Codable, Equatable {
    /// The CDN type where the message backup is stored. Media may be stored elsewhere.
    public let cdn: Int32

    /// The base directory of your backup data on the cdn. The message backup can befound in the
    /// returned cdn at /backupDir/backupName and stored media can be found at /backupDir/mediaDir/mediaId
    public let backupDir: String

    /// The prefix path component for media objects on a cdn. Stored media for mediaId
    /// can be found at /backupDir/mediaDir/mediaId.
    public let mediaDir: String

    /// The name of the most recent message backup on the cdn. The backup is at /backupDir/backupName
    public let backupName: String

    /// The amount of space used to store media
    let usedSpace: Int64
}
