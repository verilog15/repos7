//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import PassKit
import SignalServiceKit
import SignalUI

extension DonateViewController {
    /// Handle Apple Pay authorization for a one-time payment.
    ///
    /// See also: code for other payment methods, such as credit/debit cards.
    func paymentAuthorizationControllerForOneTime(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        var hasCalledCompletion = false
        func wrappedCompletion(_ result: PKPaymentAuthorizationResult) {
            guard !hasCalledCompletion else { return }
            hasCalledCompletion = true
            completion(result)
        }

        guard let oneTime = state.oneTime, let amount = oneTime.amount else {
            owsFail("Amount or currency code are missing")
        }

        let boostBadge = oneTime.profileBadge

        Promise.wrapAsync {
            try await Stripe.boost(
                amount: amount,
                level: .boostBadge,
                for: .applePay(payment: payment)
            )
        }.done(on: DispatchQueue.main) { confirmedIntent -> Void in
            owsPrecondition(
                confirmedIntent.redirectToUrl == nil,
                "[Donations] There shouldn't be a 3DS redirect for Apple Pay"
            )

            wrappedCompletion(.init(status: .success, errors: nil))

            let redemptionPromise = Promise.wrapAsync {
                try await DonationSubscriptionManager.requestAndRedeemReceipt(
                    boostPaymentIntentId: confirmedIntent.paymentIntentId,
                    amount: amount,
                    paymentProcessor: .stripe,
                    paymentMethod: .applePay
                )
            }

            DonationViewsUtil.wrapPromiseInProgressView(
                from: self,
                promise: DonationViewsUtil.waitForRedemptionJob(redemptionPromise, paymentMethod: .applePay)
            ).done(on: DispatchQueue.main) {
                self.didCompleteDonation(
                    receiptCredentialSuccessMode: .oneTimeBoost
                )
            }.catch(on: DispatchQueue.main) { [weak self] error in
                self?.didFailDonation(
                    error: error,
                    mode: .oneTime,
                    badge: boostBadge,
                    paymentMethod: .applePay
                )
            }
        }.catch(on: DispatchQueue.main) { error in
            wrappedCompletion(.init(status: .failure, errors: [error]))
            owsFailDebugUnlessNetworkFailure(error)
        }
    }
}
