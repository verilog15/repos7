//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

public protocol SignalSessionStore: LibSignalClient.SessionStore {
    func mightContainSession(
        for recipient: SignalRecipient,
        tx: DBReadTransaction
    ) -> Bool

    func mergeRecipient(
        _ recipient: SignalRecipient,
        into targetRecipient: SignalRecipient,
        tx: DBWriteTransaction
    )

    func archiveAllSessions(
        for serviceId: ServiceId,
        tx: DBWriteTransaction
    )

    /// Deprecated. Prefer the variant that accepts a ServiceId.
    func archiveAllSessions(
        for address: SignalServiceAddress,
        tx: DBWriteTransaction
    )

    func archiveSession(
        for serviceId: ServiceId,
        deviceId: DeviceId,
        tx: DBWriteTransaction
    )

    func loadSession(
        for serviceId: ServiceId,
        deviceId: DeviceId,
        tx: DBReadTransaction
    ) throws -> SessionRecord?

    func loadSession(
        for address: ProtocolAddress,
        context: StoreContext
    ) throws -> SessionRecord?

    func resetSessionStore(tx: DBWriteTransaction)

    func deleteAllSessions(
        for serviceId: ServiceId,
        tx: DBWriteTransaction
    )

    func deleteAllSessions(
        for recipientUniqueId: RecipientUniqueId,
        tx: DBWriteTransaction
    )

    func removeAll(tx: DBWriteTransaction)
}
