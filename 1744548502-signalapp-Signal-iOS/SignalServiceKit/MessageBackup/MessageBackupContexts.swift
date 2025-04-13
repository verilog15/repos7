//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

extension MessageBackup {

    /// Base context class used for archiving (creating a backup).
    ///
    /// Requires a write tx on init; we want to hold the write lock while
    /// creating a backup to avoid races with e.g. message processing.
    ///
    /// But only exposes a read tx, because we explicitly do not want
    /// archiving to be updating the database, just reading from it.
    /// (The exception to this is enqueuing attachment uploads.)
    open class ArchivingContext {
        struct IncludedContentFilter {
            /// The minimum absolute expiration time for a message, such that it
            /// is eligible for inclusion.
            ///
            /// For example, a value of 24h will exclude messages with a
            /// "lifetime" of a day or less, regardless of whether they have
            /// been read and their expiration timer has started.
            let minExpirationTimeMs: UInt64

            /// The minimum remaining time before a message will expire, such
            /// that it is eligible for inclusion.
            ///
            /// For example, a value of 24h will exclude messages that will
            /// expire in the next day, regardless of how long their original
            /// "lifetime" was.
            let minRemainingTimeUntilExpirationMs: UInt64

            /// Whether or not the plaintext SVR PIN should be included.
            let shouldIncludePin: Bool
        }

        /// For benchmarking archive steps.
        let bencher: MessageBackup.ArchiveBencher

        /// Parameters configuring what content is included in this archive.
        let includedContentFilter: IncludedContentFilter

        /// The timestamp at which the archiving process started.
        let startTimestampMs: UInt64

        private let _tx: DBWriteTransaction
        var tx: DBReadTransaction { _tx }

        /// Nil if not a paid backups account.
        private let currentBackupAttachmentUploadEra: String?
        private let backupAttachmentUploadManager: BackupAttachmentUploadManager

        init(
            backupAttachmentUploadManager: BackupAttachmentUploadManager,
            bencher: MessageBackup.ArchiveBencher,
            currentBackupAttachmentUploadEra: String?,
            includedContentFilter: IncludedContentFilter,
            startTimestampMs: UInt64,
            tx: DBWriteTransaction
        ) {
            self.bencher = bencher
            self.backupAttachmentUploadManager = backupAttachmentUploadManager
            self.currentBackupAttachmentUploadEra = currentBackupAttachmentUploadEra
            self.includedContentFilter = includedContentFilter
            self.startTimestampMs = startTimestampMs
            self._tx = tx
        }

        func enqueueAttachmentForUploadIfNeeded(_ referencedAttachment: ReferencedAttachment) throws {
            guard let currentBackupAttachmentUploadEra else {
                return
            }
            try backupAttachmentUploadManager.enqueueIfNeeded(
                referencedAttachment,
                currentUploadEra: currentBackupAttachmentUploadEra,
                tx: _tx
            )
        }
    }

    /// Base context class used for restoring from a backup.
    open class RestoringContext {

        /// The timestamp at which we began restoring.
        public let startTimestampMs: UInt64

        public let tx: DBWriteTransaction

        init(
            startTimestampMs: UInt64,
            tx: DBWriteTransaction
        ) {
            self.startTimestampMs = startTimestampMs
            self.tx = tx
        }
    }
}
