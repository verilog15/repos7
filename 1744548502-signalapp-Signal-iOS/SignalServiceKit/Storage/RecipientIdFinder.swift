//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

public typealias RecipientUniqueId = String

public enum RecipientIdError: Error, IsRetryableProvider {
    /// We can't use the Pni because it's been replaced by an Aci.
    case mustNotUsePniBecauseAciExists

    public var isRetryableProvider: Bool {
        // Allow retries so that we send to the Aci instead of the Pni.
        return true
    }
}

public final class RecipientIdFinder {
    private let recipientDatabaseTable: RecipientDatabaseTable
    private let recipientFetcher: RecipientFetcher

    public init(
        recipientDatabaseTable: RecipientDatabaseTable,
        recipientFetcher: RecipientFetcher
    ) {
        self.recipientFetcher = recipientFetcher
        self.recipientDatabaseTable = recipientDatabaseTable
    }

    public func recipientUniqueId(for serviceId: ServiceId, tx: DBReadTransaction) -> Result<RecipientUniqueId, RecipientIdError>? {
        guard let recipient = recipientDatabaseTable.fetchRecipient(serviceId: serviceId, transaction: tx) else {
            return nil
        }
        return recipientUniqueIdResult(for: serviceId, recipient: recipient)
    }

    public func recipientUniqueId(for address: SignalServiceAddress, tx: DBReadTransaction) -> Result<RecipientUniqueId, RecipientIdError>? {
        guard
            let recipient = DependenciesBridge.shared.recipientDatabaseTable
                .fetchRecipient(address: address, tx: tx)
        else {
            return nil
        }

        return recipientUniqueIdResult(for: address.serviceId, recipient: recipient)
    }

    public func ensureRecipientUniqueId(for serviceId: ServiceId, tx: DBWriteTransaction) -> Result<RecipientUniqueId, RecipientIdError> {
        let recipient = recipientFetcher.fetchOrCreate(serviceId: serviceId, tx: tx)
        return recipientUniqueIdResult(for: serviceId, recipient: recipient)
    }

    private func recipientUniqueIdResult(for serviceId: ServiceId?, recipient: SignalRecipient) -> Result<RecipientUniqueId, RecipientIdError> {
        if serviceId is Pni, recipient.aciString != nil {
            return .failure(.mustNotUsePniBecauseAciExists)
        }
        return .success(recipient.uniqueId)
    }
}

public final class OWSAccountIdFinder {
    public class func ensureRecipient(
        forAddress address: SignalServiceAddress,
        transaction: DBWriteTransaction
    ) -> SignalRecipient {
        let recipientFetcher = DependenciesBridge.shared.recipientFetcher
        let recipient: SignalRecipient
        if let serviceId = address.serviceId {
            recipient = recipientFetcher.fetchOrCreate(serviceId: serviceId, tx: transaction)
        } else if let phoneNumber = address.e164 {
            recipient = recipientFetcher.fetchOrCreate(phoneNumber: phoneNumber, tx: transaction)
        } else {
            // This can happen for historical reasons. It shouldn't happen, but it
            // could. We could return [[NSUUID UUID] UUIDString] and avoid persisting
            // anything to disk. However, it's possible that a caller may expect to be
            // able to fetch the recipient based on the value we return, so we need to
            // ensure that the return value can be fetched. In the future, we should
            // update all callers to ensure they pass valid addresses.
            owsFailDebug("Fetching accountId for invalid address.")
            recipient = SignalRecipient(aci: nil, pni: nil, phoneNumber: nil)
            recipient.anyInsert(transaction: transaction)
        }
        return recipient
    }
}
