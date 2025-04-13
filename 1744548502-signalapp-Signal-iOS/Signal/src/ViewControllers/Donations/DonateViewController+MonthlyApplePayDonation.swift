//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import PassKit
import SignalServiceKit
import SignalUI

extension DonateViewController {
    /// Handle Apple Pay authorization for a monthly payment.
    ///
    /// See also: code for other payment methods, such as credit/debit cards.
    func paymentAuthorizationControllerForMonthly(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        guard
            let monthly = state.monthly,
            let selectedSubscriptionLevel = monthly.selectedSubscriptionLevel
        else {
            owsFail("[Donations] Invalid state; cannot pay")
        }

        Logger.info("[Donations] Starting monthly Apple Pay donation")

        // See also: code for other payment methods, such as credit/debit card.
        firstly(on: DispatchQueue.sharedUserInitiated) { () -> Promise<Void> in
            if let existingSubscriberId = monthly.subscriberID {
                Logger.info("[Donations] Cancelling existing subscription")

                return Promise.wrapAsync {
                    try await DonationSubscriptionManager.cancelSubscription(for: existingSubscriberId)
                }
            } else {
                Logger.info("[Donations] No existing subscription to cancel")

                return Promise.value(())
            }
        }.then(on: DispatchQueue.sharedUserInitiated) { () -> Promise<Data> in
            Logger.info("[Donations] Preparing new monthly subscription with Apple Pay")

            return Promise.wrapAsync {
                try await DonationSubscriptionManager.prepareNewSubscription(
                    currencyCode: monthly.selectedCurrencyCode
                )
            }
        }.then(on: DispatchQueue.sharedUserInitiated) { subscriberId -> Promise<(Data, String)> in
            Promise.wrapAsync { () -> String in
                Logger.info("[Donations] Creating Signal payment method for new monthly subscription with Apple Pay")
                return try await Stripe.createSignalPaymentMethodForSubscription(subscriberId: subscriberId)
            }.then(on: DispatchQueue.sharedUserInitiated) { clientSecret -> Promise<Stripe.ConfirmedSetupIntent> in
                Logger.info("[Donations] Authorizing payment for new monthly subscription with Apple Pay")

                return Promise.wrapAsync {
                    return try await Stripe.setupNewSubscription(
                        clientSecret: clientSecret,
                        paymentMethod: .applePay(payment: payment)
                    )
                }
            }.map(on: DispatchQueue.sharedUserInitiated) { confirmedIntent in
                (subscriberId, confirmedIntent.paymentMethodId)
            }
        }.then(on: DispatchQueue.sharedUserInitiated) { (subscriberId, paymentMethodId) -> Promise<Data> in
            Logger.info("[Donations] Finalizing new subscription for Apple Pay donation")

            return Promise.wrapAsync {
                try await DonationSubscriptionManager.finalizeNewSubscription(
                    forSubscriberId: subscriberId,
                    paymentType: .applePay(paymentMethodId: paymentMethodId),
                    subscription: selectedSubscriptionLevel,
                    currencyCode: monthly.selectedCurrencyCode
                )
            }.map(on: DispatchQueue.sharedUserInitiated) { _ in subscriberId }
        }.done(on: DispatchQueue.main) { subscriberID in
            let authResult = PKPaymentAuthorizationResult(status: .success, errors: nil)
            completion(authResult)

            Logger.info("[Donations] Redeeming monthly receipt for Apple Pay donation")

            let redemptionPromise = Promise.wrapAsync {
                try await DonationSubscriptionManager.requestAndRedeemReceipt(
                    subscriberId: subscriberID,
                    subscriptionLevel: selectedSubscriptionLevel.level,
                    priorSubscriptionLevel: monthly.currentSubscriptionLevel?.level,
                    paymentProcessor: .stripe,
                    paymentMethod: .applePay,
                    isNewSubscription: true
                )
            }

            DonationViewsUtil.wrapPromiseInProgressView(
                from: self,
                promise: DonationViewsUtil.waitForRedemptionJob(redemptionPromise, paymentMethod: .applePay)
            ).done(on: DispatchQueue.main) {
                Logger.info("[Donations] Monthly card donation finished")

                self.didCompleteDonation(
                    receiptCredentialSuccessMode: .recurringSubscriptionInitiation
                )
            }.catch(on: DispatchQueue.main) { [weak self] error in
                Logger.info("[Donations] Monthly card donation failed")

                self?.didFailDonation(
                    error: error,
                    mode: .monthly,
                    badge: selectedSubscriptionLevel.badge,
                    paymentMethod: .applePay
                )
            }
        }.catch(on: DispatchQueue.main) { error in
            let authResult = PKPaymentAuthorizationResult(status: .failure, errors: [error])
            completion(authResult)
            owsFailDebug("[Donations] Error setting up subscription, \(error)")
        }
    }
}
