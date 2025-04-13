//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

extension TSInvalidIdentityKeyReceivingErrorMessage {
    @objc(identityKeyFromEncodedPreKeySignalMessage:error:)
    func identityKey(from encodedPreKeySignalMessage: Data) throws -> Data {
        return Data(try PreKeySignalMessage(bytes: encodedPreKeySignalMessage).identityKey.keyBytes)
    }

    @objc
    public func decrypt(messagesToDecrypt: [TSInvalidIdentityKeyReceivingErrorMessage]?) {
        AssertIsOnMainThread()

        guard let messagesToDecrypt = messagesToDecrypt else {
            return
        }

        for errorMessage in messagesToDecrypt {
            guard let envelopeData = errorMessage.envelopeData else {
                owsFailDebug("Missing envelopeData.")
                continue
            }
            SSKEnvironment.shared.messageProcessorRef.processReceivedEnvelopeData(
                envelopeData,
                serverDeliveryTimestamp: 0,
                envelopeSource: .identityChangeError
            ) { _ in
                // Here we remove the existing error message because handleReceivedEnvelope will
                // either
                //  1.) succeed and create a new successful message in the thread or...
                //  2.) fail and create a new identical error message in the thread.
                SSKEnvironment.shared.databaseStorageRef.write { tx in
                    if let existingError = TSInteraction.anyFetch(
                        uniqueId: errorMessage.uniqueId, transaction: tx
                    ) {
                        DependenciesBridge.shared.interactionDeleteManager
                            .delete(existingError, sideEffects: .default(), tx: tx)
                    }
                }
            }
        }
    }
}
