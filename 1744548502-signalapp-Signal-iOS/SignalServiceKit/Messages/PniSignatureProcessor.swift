//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

protocol PniSignatureProcessor {
    func handlePniSignature(
        _ pniSignatureMessage: SSKProtoPniSignatureMessage,
        from sourceAci: Aci,
        localIdentifiers: LocalIdentifiers,
        tx: DBWriteTransaction
    ) throws
}

enum PniSignatureProcessorError: Error {
    case malformedProtobuf
    case missingIdentityKey
    case invalidSignature
}

final class PniSignatureProcessorImpl: PniSignatureProcessor {
    private let identityManager: OWSIdentityManager
    private let recipientDatabaseTable: RecipientDatabaseTable
    private let recipientMerger: RecipientMerger

    init(
        identityManager: OWSIdentityManager,
        recipientDatabaseTable: RecipientDatabaseTable,
        recipientMerger: RecipientMerger
    ) {
        self.identityManager = identityManager
        self.recipientDatabaseTable = recipientDatabaseTable
        self.recipientMerger = recipientMerger
    }

    func handlePniSignature(
        _ pniSignatureMessage: SSKProtoPniSignatureMessage,
        from aci: Aci,
        localIdentifiers: LocalIdentifiers,
        tx: DBWriteTransaction
    ) throws {
        guard let pniData = pniSignatureMessage.pni, let pniUuid = UUID(data: pniData) else {
            throw PniSignatureProcessorError.malformedProtobuf
        }
        let pni = Pni(fromUUID: pniUuid)
        guard let pniIdentityKey = try identityManager.identityKey(for: pni, tx: tx) else {
            throw PniSignatureProcessorError.missingIdentityKey
        }
        guard let aciIdentityKey = try identityManager.identityKey(for: aci, tx: tx) else {
            throw PniSignatureProcessorError.missingIdentityKey
        }
        guard let signatureData = pniSignatureMessage.signature else {
            throw PniSignatureProcessorError.malformedProtobuf
        }
        guard try pniIdentityKey.verifyAlternateIdentity(aciIdentityKey, signature: signatureData) else {
            throw PniSignatureProcessorError.invalidSignature
        }
        recipientMerger.applyMergeFromPniSignature(localIdentifiers: localIdentifiers, aci: aci, pni: pni, tx: tx)
    }
}
