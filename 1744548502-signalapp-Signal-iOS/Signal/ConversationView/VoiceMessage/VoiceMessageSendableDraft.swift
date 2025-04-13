//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import CoreServices
import Foundation
import SignalServiceKit
import UniformTypeIdentifiers

protocol VoiceMessageSendableDraft {
    func prepareForSending() throws -> URL
}

extension VoiceMessageSendableDraft {
    private func userVisibleFilename(currentDate: Date) -> String {
        String(
            format: "%@ %@.%@",
            OWSLocalizedString("VOICE_MESSAGE_FILE_NAME", comment: "Filename for voice messages."),
            DateFormatter.localizedString(from: currentDate, dateStyle: .short, timeStyle: .short),
            VoiceMessageConstants.fileExtension
        )
    }

    func prepareAttachment() throws -> SignalAttachment {
        let attachmentUrl = try prepareForSending()

        let dataSource = try DataSourcePath(fileUrl: attachmentUrl, shouldDeleteOnDeallocation: true)
        dataSource.sourceFilename = userVisibleFilename(currentDate: Date())

        let attachment = SignalAttachment.voiceMessageAttachment(dataSource: dataSource, dataUTI: UTType.mpeg4Audio.identifier)
        guard !attachment.hasError else {
            throw OWSAssertionError("Failed to create voice message attachment: \(attachment.errorName ?? "Unknown Error")")
        }
        return attachment
    }
}
