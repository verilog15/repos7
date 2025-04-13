//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import AuthenticationServices
import Foundation
import SignalServiceKit
import SignalUI

extension DonateViewController {
    /// Executes a PayPal one-time donation flow.
    func startPaypalBoost(
        with amount: FiatMoney,
        badge: ProfileBadge
    ) {
        Logger.info("[Donations] Starting one-time PayPal donation")

        firstly(on: DispatchQueue.main) { [weak self] () -> Promise<(URL, String)> in
            guard let self else { throw OWSAssertionError("[Donations] Missing self!") }

            Logger.info("[Donations] Creating one-time PayPal payment")
            return Promise.wrapAsync {
                try await DonationViewsUtil.Paypal.createPaypalPaymentBehindActivityIndicator(
                    amount: amount,
                    level: .boostBadge,
                    fromViewController: self
                )
            }
        }.then(on: DispatchQueue.main) { [weak self] (approvalUrl, paymentId) -> Promise<(Paypal.OneTimePaymentWebAuthApprovalParams, String)> in
            guard let self else { throw OWSAssertionError("[Donations] Missing self!") }

            Logger.info("[Donations] Presenting PayPal web UI for user approval of one-time donation")
            return Promise.wrapAsync {
                let approvalParams: Paypal.OneTimePaymentWebAuthApprovalParams = try await Paypal.presentExpectingApprovalParams(
                    approvalUrl: approvalUrl,
                    withPresentationContext: self
                )
                return (approvalParams, paymentId)
            }
        }.then(on: DispatchQueue.main) { [weak self] (approvalParams, paymentId) -> Promise<Void> in
            guard let self else { return .value(()) }

            Logger.info("[Donations] Creating and redeeming one-time boost receipt for PayPal donation")
            return DonationViewsUtil.wrapPromiseInProgressView(
                from: self,
                promise: Promise.wrapAsync {
                    try await self.confirmPaypalPaymentAndRedeemBoost(
                        amount: amount,
                        paymentId: paymentId,
                        approvalParams: approvalParams
                    )
                }
            )
        }.done(on: DispatchQueue.main) { [weak self] in
            guard let self else { return }

            Logger.info("[Donations] One-time PayPal donation finished")
            self.didCompleteDonation(
                receiptCredentialSuccessMode: .oneTimeBoost
            )
        }.catch(on: DispatchQueue.main) { [weak self] error in
            guard let self else { return }

            if let webAuthError = error as? Paypal.AuthError {
                switch webAuthError {
                case .userCanceled:
                    Logger.info("[Donations] One-time PayPal donation canceled")
                    self.didCancelDonation()
                }
            } else {
                Logger.info("[Donations] One-time PayPal donation failed")
                self.didFailDonation(
                    error: error,
                    mode: .oneTime,
                    badge: badge,
                    paymentMethod: .paypal
                )
            }
        }
    }

    private func confirmPaypalPaymentAndRedeemBoost(
        amount: FiatMoney,
        paymentId: String,
        approvalParams: Paypal.OneTimePaymentWebAuthApprovalParams
    ) async throws {
        let paymentIntentId = try await Paypal.confirmOneTimePayment(
            amount: amount,
            level: .boostBadge,
            paymentId: paymentId,
            approvalParams: approvalParams
        )

        try await DonationViewsUtil.waitForRedemption(paymentMethod: .paypal) {
            try await DonationSubscriptionManager.requestAndRedeemReceipt(
                boostPaymentIntentId: paymentIntentId,
                amount: amount,
                paymentProcessor: .braintree,
                paymentMethod: .paypal
            )
        }
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension DonateViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window!
    }
}
