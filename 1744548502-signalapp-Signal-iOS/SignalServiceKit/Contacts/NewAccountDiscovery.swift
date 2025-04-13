//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

public enum NewAccountDiscovery {
    public static func postNotification(for recipient: SignalRecipient, tx: DBWriteTransaction) {
        if recipient.address.isLocalAddress {
            return
        }

        guard TSContactThread.getWithContactAddress(recipient.address, transaction: tx) == nil else {
            return
        }

        let thread = TSContactThread.getOrCreateThread(withContactAddress: recipient.address, transaction: tx)
        let message = TSInfoMessage(thread: thread, messageType: .userJoinedSignal)
        message.anyInsert(transaction: tx)

        // Keep these notifications less obtrusive by making them silent.
        SSKEnvironment.shared.notificationPresenterRef.notifyUser(
            forTSMessage: message,
            thread: thread,
            wantsSound: false,
            transaction: tx
        )
    }
}
