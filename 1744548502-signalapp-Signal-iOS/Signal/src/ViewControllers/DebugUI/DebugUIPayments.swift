//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

#if USE_DEBUG_UI

class DebugUIPayments: DebugUIPage {

    let name = "Payments"

    func section(thread: TSThread?) -> OWSTableSection? {
        var sectionItems = [OWSTableItem]()

        if let contactThread = thread as? TSContactThread {
            sectionItems.append(OWSTableItem(title: "Create all possible payment models") { [weak self] in
                self?.insertAllPaymentModelVariations(contactThread: contactThread)
            })
            sectionItems.append(OWSTableItem(title: "Send tiny payments: 10") {
                Self.sendTinyPayments(contactThread: contactThread, count: 10)
            })
            // For testing defragmentation.
            sectionItems.append(OWSTableItem(title: "Send tiny payments: 17") {
                Self.sendTinyPayments(contactThread: contactThread, count: 17)
            })
            // For testing defragmentation.
            sectionItems.append(OWSTableItem(title: "Send tiny payments: 40") {
                Self.sendTinyPayments(contactThread: contactThread, count: 40)
            })
            // For testing defragmentation.
            sectionItems.append(OWSTableItem(title: "Send tiny payments: 100") {
                Self.sendTinyPayments(contactThread: contactThread, count: 100)
            })
            sectionItems.append(OWSTableItem(title: "Send tiny payments: 1000") {
                Self.sendTinyPayments(contactThread: contactThread, count: 1000)
            })
        }

        sectionItems.append(OWSTableItem(title: "Delete all payment models") { [weak self] in
            self?.deleteAllPaymentModels()
        })
        sectionItems.append(OWSTableItem(title: "Reconcile now") {
            SSKEnvironment.shared.databaseStorageRef.write { transaction in
                SUIEnvironment.shared.paymentsRef.scheduleReconciliationNow(transaction: transaction)
            }
        })

        return OWSTableSection(title: "Payments", items: sectionItems)
    }

    // MARK: -

    private func insertAllPaymentModelVariations(contactThread: TSContactThread) {
        let address = contactThread.contactAddress
        let aci = address.aci!

        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            let paymentAmounts = [
                TSPaymentAmount(currency: .mobileCoin, picoMob: 1),
                TSPaymentAmount(currency: .mobileCoin, picoMob: 1000),
                TSPaymentAmount(currency: .mobileCoin, picoMob: 1000 * 1000),
                TSPaymentAmount(currency: .mobileCoin, picoMob: 1000 * 1000 * 1000),
                TSPaymentAmount(currency: .mobileCoin, picoMob: 1000 * 1000 * 1000 * 1000),
                TSPaymentAmount(currency: .mobileCoin, picoMob: 1000 * 1000 * 1000 * 1000 * 1000)
            ]

            func insertPaymentModel(paymentType: TSPaymentType,
                                    paymentState: TSPaymentState) -> TSPaymentModel {
                let mcReceiptData = Randomness.generateRandomBytes(32)
                var mcTransactionData: Data?
                if paymentState.isIncoming {
                } else {
                    mcTransactionData = Randomness.generateRandomBytes(32)
                }
                var memoMessage: String?
                if Bool.random() {
                    memoMessage = "Pizza Party 🍕"
                }
                // TODO: requestUuidString
                // TODO: isUnread
                // TODO: mcRecipientPublicAddressData
                // TODO: mobileCoin
                // TODO: feeAmount

                let mobileCoin = MobileCoinPayment(recipientPublicAddressData: nil,
                                                   transactionData: mcTransactionData,
                                                   receiptData: mcReceiptData,
                                                   incomingTransactionPublicKeys: nil,
                                                   spentKeyImages: nil,
                                                   outputPublicKeys: nil,
                                                   ledgerBlockTimestamp: 0,
                                                   ledgerBlockIndex: 0,
                                                   feeAmount: nil)

                let paymentModel = TSPaymentModel(paymentType: paymentType,
                                                  paymentState: paymentState,
                                                  paymentAmount: paymentAmounts.randomElement()!,
                                                  createdDate: Date(),
                                                  senderOrRecipientAci: paymentType.isUnidentified ? nil : AciObjC(aci),
                                                  memoMessage: memoMessage,
                                                  isUnread: false,
                                                  interactionUniqueId: nil,
                                                  mobileCoin: mobileCoin)
                do {
                    try SSKEnvironment.shared.paymentsHelperRef.tryToInsertPaymentModel(paymentModel, transaction: transaction)
                } catch {
                    owsFailDebug("Error: \(error)")
                }
                return paymentModel
            }

            var paymentModel: TSPaymentModel

            // MARK: - Incoming

            paymentModel = insertPaymentModel(paymentType: .incomingPayment, paymentState: .incomingUnverified)
            paymentModel = insertPaymentModel(paymentType: .incomingPayment, paymentState: .incomingVerified)
            paymentModel = insertPaymentModel(paymentType: .incomingPayment, paymentState: .incomingComplete)

            // MARK: - Outgoing

            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingUnsubmitted)
            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingUnverified)
            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingVerified)
            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingSending)
            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingSent)
            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingComplete)

            // MARK: - Failures

            // TODO: We probably don't want to create .none and .unknown
//            paymentModel = insertPaymentModel(paymentState: .outgoingFailed)
//            paymentModel.update(withPaymentFailure: .none,
//                                paymentState: .outgoingFailed,
//                                transaction: transaction)
//
//            paymentModel = insertPaymentModel(paymentState: .incomingFailed)
//            paymentModel.update(withPaymentFailure: .none,
//                                paymentState: .incomingFailed,
//                                transaction: transaction)
//
//            paymentModel = insertPaymentModel(paymentState: .outgoingFailed)
//            paymentModel.update(withPaymentFailure: .unknown,
//                                paymentState: .outgoingFailed,
//                                transaction: transaction)
//
//            paymentModel = insertPaymentModel(paymentState: .incomingFailed)
//            paymentModel.update(withPaymentFailure: .unknown,
//                                paymentState: .incomingFailed,
//                                transaction: transaction)

            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingFailed)
            paymentModel.update(withPaymentFailure: .insufficientFunds,
                                paymentState: .outgoingFailed,
                                transaction: transaction)

            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingFailed)
            paymentModel.update(withPaymentFailure: .validationFailed,
                                paymentState: .outgoingFailed,
                                transaction: transaction)

            paymentModel = insertPaymentModel(paymentType: .incomingPayment, paymentState: .incomingFailed)
            paymentModel.update(withPaymentFailure: .validationFailed,
                                paymentState: .incomingFailed,
                                transaction: transaction)

            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingFailed)
            paymentModel.update(withPaymentFailure: .notificationSendFailed,
                                paymentState: .outgoingFailed,
                                transaction: transaction)

            paymentModel = insertPaymentModel(paymentType: .incomingPayment, paymentState: .incomingFailed)
            paymentModel.update(withPaymentFailure: .invalid,
                                paymentState: .incomingFailed,
                                transaction: transaction)

            paymentModel = insertPaymentModel(paymentType: .outgoingPayment, paymentState: .outgoingFailed)
            paymentModel.update(withPaymentFailure: .invalid,
                                paymentState: .outgoingFailed,
                                transaction: transaction)

            // MARK: - Unidentified

            paymentModel = insertPaymentModel(paymentType: .incomingUnidentified, paymentState: .incomingComplete)
            paymentModel = insertPaymentModel(paymentType: .outgoingUnidentified, paymentState: .outgoingComplete)
        }
    }

    private static func sendTinyPayments(contactThread: TSContactThread, count: UInt) {
        let picoMob = PaymentsConstants.picoMobPerMob + UInt64.random(in: 0..<1000)
        let paymentAmount = TSPaymentAmount(currency: .mobileCoin, picoMob: picoMob)
        let recipient = SendPaymentRecipientImpl.address(address: contactThread .contactAddress)
        firstly(on: DispatchQueue.global()) { () -> Promise<PreparedPayment> in
            SUIEnvironment.shared.paymentsImplRef.prepareOutgoingPayment(
                recipient: recipient,
                paymentAmount: paymentAmount,
                memoMessage: "Tiny: \(count)",
                isOutgoingTransfer: false,
                canDefragment: false
            )
        }.then(on: DispatchQueue.global()) { (preparedPayment: PreparedPayment) in
            SUIEnvironment.shared.paymentsImplRef.initiateOutgoingPayment(preparedPayment: preparedPayment)
        }.then(on: DispatchQueue.global()) { (paymentModel: TSPaymentModel) in
            SUIEnvironment.shared.paymentsImplRef.blockOnOutgoingVerification(paymentModel: paymentModel)
        }.done(on: DispatchQueue.global()) { _ in
            if count > 1 {
                Self.sendTinyPayments(contactThread: contactThread, count: count - 1)
            } else {
                Logger.info("Complete.")
            }
        }.catch(on: DispatchQueue.global()) { error in
            owsFailDebug("Error: \(error)")
        }
    }

    private func deleteAllPaymentModels() {
        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            TSPaymentModel.anyRemoveAllWithInstantiation(transaction: transaction)
        }
    }
}

#endif
