//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalServiceKit

extension DonationPaymentDetailsViewController {
    /// Make a monthly donation.
    ///
    /// See also: code for other payment methods, such as Apple Pay.
    func monthlyDonation(
        with validForm: FormState.ValidForm,
        newSubscriptionLevel: DonationSubscriptionLevel,
        priorSubscriptionLevel: DonationSubscriptionLevel?,
        subscriberID existingSubscriberId: Data?
    ) {
        let currencyCode = self.donationAmount.currencyCode
        let donationStore = DependenciesBridge.shared.externalPendingIDEALDonationStore

        Logger.info("[Donations] Starting monthly donation")

        DonationViewsUtil.wrapPromiseInProgressView(
            from: self,
            promise: firstly(on: DispatchQueue.sharedUserInitiated) { () -> Promise<Void> in
                if let existingSubscriberId {
                    Logger.info("[Donations] Cancelling existing subscription")

                    return Promise.wrapAsync {
                        try await DonationSubscriptionManager.cancelSubscription(for: existingSubscriberId)
                    }
                } else {
                    Logger.info("[Donations] No existing subscription to cancel")

                    return Promise.value(())
                }
            }.then(on: DispatchQueue.sharedUserInitiated) { () -> Promise<Data> in
                Logger.info("[Donations] Preparing new monthly subscription")

                return Promise.wrapAsync {
                    try await DonationSubscriptionManager.prepareNewSubscription(currencyCode: currencyCode)
                }
            }.then(on: DispatchQueue.sharedUserInitiated) { subscriberId -> Promise<(Data, DonationSubscriptionManager.RecurringSubscriptionPaymentType)> in
                Promise.wrapAsync { () -> String in
                    Logger.info("[Donations] Creating Signal payment method for new monthly subscription")
                    return try await Stripe.createSignalPaymentMethodForSubscription(subscriberId: subscriberId)
                }.then(on: DispatchQueue.sharedUserInitiated) { clientSecret -> Promise<DonationSubscriptionManager.RecurringSubscriptionPaymentType> in
                    Logger.info("[Donations] Authorizing payment for new monthly subscription")

                    return Promise.wrapAsync {
                        return try await Stripe.setupNewSubscription(
                            clientSecret: clientSecret,
                            paymentMethod: validForm.stripePaymentMethod
                        )
                    }.then(on: DispatchQueue.sharedUserInitiated) { confirmedIntent -> Promise<Stripe.ConfirmedSetupIntent> in
                        if let redirectToUrl = confirmedIntent.redirectToUrl {
                            if case .ideal = validForm.donationPaymentMethod {
                                Logger.info("[Donations] Subscription requires iDEAL authentication. Presenting...")
                                let confirmedDonation = PendingMonthlyIDEALDonation(
                                    subscriberId: subscriberId,
                                    clientSecret: clientSecret,
                                    setupIntentId: confirmedIntent.setupIntentId,
                                    newSubscriptionLevel: newSubscriptionLevel,
                                    oldSubscriptionLevel: priorSubscriptionLevel,
                                    amount: self.donationAmount
                                )
                                SSKEnvironment.shared.databaseStorageRef.write { tx in
                                    do {
                                        try donationStore.setPendingSubscription(donation: confirmedDonation, tx: tx)
                                    } catch {
                                        owsFailDebug("[Donations] Failed to persist pending iDEAL subscription.")
                                    }
                                }
                            } else {
                                Logger.info("[Donations] Subscription requires 3DS authentication. Presenting...")
                            }
                            return self.show3DS(for: redirectToUrl)
                                .map(on: DispatchQueue.sharedUserInitiated) { _ in
                                    return confirmedIntent
                                }
                        } else {
                            return Promise.value(confirmedIntent)
                        }
                    }.map { confirmedIntent in
                        switch validForm {
                        case .card:
                            return .creditOrDebitCard(paymentMethodId: confirmedIntent.paymentMethodId)
                        case .sepa:
                            return .sepa(paymentMethodId: confirmedIntent.paymentMethodId)
                        case .ideal:
                            return .ideal(setupIntentId: confirmedIntent.setupIntentId)
                        }
                    }
                }.map(on: DispatchQueue.sharedUserInitiated) { paymentType -> (Data, DonationSubscriptionManager.RecurringSubscriptionPaymentType) in
                    (subscriberId, paymentType)
                }
            }.then(on: DispatchQueue.sharedUserInitiated) { (subscriberId, paymentType) in
                return Promise.wrapAsync {
                    try await DonationViewsUtil.completeMonthlyDonations(
                        subscriberId: subscriberId,
                        paymentType: paymentType,
                        newSubscriptionLevel: newSubscriptionLevel,
                        priorSubscriptionLevel: priorSubscriptionLevel,
                        currencyCode: currencyCode,
                        databaseStorage: SSKEnvironment.shared.databaseStorageRef
                    )
                }
            }
        ).done(on: DispatchQueue.main) { [weak self] in
            Logger.info("[Donations] Monthly donation finished")
            self?.onFinished(nil)
        }.catch(on: DispatchQueue.main) { [weak self] error in
            Logger.info("[Donations] Monthly donation UX dismissing w/error (might not be fatal)")
            self?.onFinished(error)
        }
    }
}
