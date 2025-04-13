//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

protocol SubscriptionRedemptionNecessityCheckerStore {
    func subscriberId(tx: DBReadTransaction) -> Data?

    func getLastRedemptionNecessaryCheck(tx: DBReadTransaction) -> Date?
    func setLastRedemptionNecessaryCheck(_ now: Date, tx: DBWriteTransaction)
}

/// Responsible for determining if we need to attempt redemption for a
/// subscription.
///
/// Broadly, once per some fixed period (at the time of writing, 1x/3d) we make
/// a series of network requests and parse/compare the results to determine if
/// we believe the subscription has been renewed. If so, we enqueue and kick off
/// a durable redemption job.
///
/// At the time of writing we have two subscription types – donations and
/// backups – which differ in their details but which also reuse much of the
/// same "subscriber ID" anonymization infrastructure. Consequently, the logic
/// we use to decide if they should be redeemed is largely the same for both,
/// and customized by blocks passed by specific callers.
struct SubscriptionRedemptionNecessityChecker<RedemptionJobRecord: JobRecord> {
    typealias ParseEntitlementExpirationBlock = (
        _ entitlements: WhoAmIRequestFactory.Responses.WhoAmI.Entitlements,
        _ subscription: Subscription
    ) -> TimeInterval?

    typealias EnqueueRedemptionJobBlock = (
        _ subscriberId: Data,
        _ subscription: Subscription,
        _ tx: DBWriteTransaction
    ) throws -> RedemptionJobRecord

    typealias StartRedemptionJobBlock = (
        _ jobRecord: RedemptionJobRecord
    ) async throws -> Void

    private enum Constants {
        static var intervalBetweenChecks: TimeInterval { 3 * .day }
    }

    private let checkerStore: SubscriptionRedemptionNecessityCheckerStore
    private let dateProvider: DateProvider
    private let db: any DB
    private let logger: PrefixedLogger
    private let networkManager: NetworkManager
    private let tsAccountManager: TSAccountManager
    private let whoAmIManager: WhoAmIManager

    init(
        checkerStore: SubscriptionRedemptionNecessityCheckerStore,
        dateProvider: @escaping DateProvider,
        db: any DB,
        logger: PrefixedLogger,
        networkManager: NetworkManager,
        tsAccountManager: TSAccountManager
    ) {
        self.checkerStore = checkerStore
        self.dateProvider = dateProvider
        self.db = db
        self.logger = logger
        self.networkManager = networkManager
        self.tsAccountManager = tsAccountManager
        self.whoAmIManager = WhoAmIManagerImpl(networkManager: networkManager)
    }

    /// Redeems the current subscription period, if necessary.
    ///
    /// - Parameter parseEntitlementExpirationBlock
    /// Returns the expiration time of the current account entitlement
    /// associated with the given subscription. For example, if the given
    /// subscription is for a donation, returns the expiration time of the
    /// associated badge entitlement.
    /// - Parameter enqueueRedemptionJobBlock
    /// Enqueues a durable redemption job. Invoked if redemption is necessary.
    /// - Parameter startRedemptionJobBlock
    /// Starts a durable redemption job previously enqueued by
    /// `enqueueRedemptionJobBlock`.
    func redeemSubscriptionIfNecessary(
        parseEntitlementExpirationBlock: ParseEntitlementExpirationBlock,
        enqueueRedemptionJobBlock: EnqueueRedemptionJobBlock,
        startRedemptionJobBlock: StartRedemptionJobBlock
    ) async throws {
        let (
            registrationState,
            subscriberId,
            lastRedemptionNecessaryCheck
        ): (
            TSRegistrationState,
            Data?,
            Date?
        ) = db.read { tx in
            return (
                tsAccountManager.registrationState(tx: tx),
                checkerStore.subscriberId(tx: tx),
                checkerStore.getLastRedemptionNecessaryCheck(tx: tx)
            )
        }

        guard let subscriberId else {
            /// If we don't have a subscriber ID, there's nothing to do.
            logger.info("Not redeeming, missing subscriber ID!")
            return
        }

        guard registrationState.isRegisteredPrimaryDevice else {
            /// Only primaries manage subscriptions!
            logger.info("Not redeeming, not a registered primary!")
            return
        }

        if
            let lastRedemptionNecessaryCheck,
            dateProvider().timeIntervalSince(lastRedemptionNecessaryCheck) < Constants.intervalBetweenChecks
        {
            /// Not necessary to check, we did so recently!
            logger.info("Not redeeming, we did so recently!")
            return
        }

        logger.info("Checking if subscription should be redeemed.")

        /// This "heartbeat" is important to do regularly, as the server will
        /// take cleanup steps on subscriber IDs that haven't had a client
        /// perform a "keep-alive" in a long time (such as canceling the
        /// associated subscription, if possible).
        try await performSubscriberIdHeartbeat(subscriberId)

        let subscription = try await SubscriptionFetcher(networkManager: networkManager)
            .fetch(subscriberID: subscriberId)

        guard let subscription else {
            logger.warn("No subscription for this subscriber ID!")

            /// No need to check again...ever, really. We could auto-delete the
            /// subscriber ID here, but we historically only do that in response
            /// to a user-initiated cancel-subscription.
            await db.awaitableWrite { tx in
                checkerStore.setLastRedemptionNecessaryCheck(dateProvider(), tx: tx)
            }

            return
        }

        let hasSubscriptionRenewedSinceLastRedemption: Bool = try await {
            let currentEntitlements = try await whoAmIManager.makeWhoAmIRequest().entitlements

            let currentEntitlementExpiration: TimeInterval? = parseEntitlementExpirationBlock(
                currentEntitlements,
                subscription
            )

            if let currentEntitlementExpiration {
                /// If the subscription expiration is after the entitlement
                /// expiration, we know it's renewed since we last redeemed.
                /// (The entitlement will last till the subscription expiration
                /// + a grace period, so if the subscription expiration is
                /// larger, it must have renewed since the entitlement was last
                /// set.)
                ///
                /// This also covers starting a new subscription after a
                /// previous one expired; we'll have an entitlement from prior
                /// redemptions, but the new subscription will definitely expire
                /// after that entitlement.
                return currentEntitlementExpiration < subscription.endOfCurrentPeriod
            }

            /// We have no entitlement, so if we have an active subscription
            /// we know we should redeem. (For example, this is the first
            /// time this user has set up a subscription.)
            ///
            /// It's important to check the subscription status, because we
            /// don't want to attempt redemption for a long-canceled
            /// subscription just because the entitlements we had from that
            /// subscription have been removed from our account.
            return subscription.active
        }()

        if
            case .pastDue = subscription.status
        {
            /// For some payment methods (e.g., cards), the payment processors
            /// will automatically retry a subscription-renewal payment failure.
            /// While that's happening, the subscription will be "past due".
            ///
            /// Retries will occur on the scale of days, for a period of weeks.
            /// We don't want to attempt badge redemption during this time since
            /// we don't expect to succeed now, but failure doesn't yet mean
            /// much as we may succeed in the future if the payment recovers.
            logger.warn("Subscription failed to renew, but payment processor is retrying. Not yet attempting receipt credential redemption for this period.")

            await db.awaitableWrite { tx in
                checkerStore.setLastRedemptionNecessaryCheck(dateProvider(), tx: tx)
            }
        } else if hasSubscriptionRenewedSinceLastRedemption {
            logger.info("Attempting to redeem subscription renewal!")

            let jobRecord: RedemptionJobRecord = try await db.awaitableWrite { tx in
                /// Enqueue a redemption job, importantly in the same transaction
                /// as we record the last-redeemed subscription details.
                let jobRecord = try enqueueRedemptionJobBlock(subscriberId, subscription, tx)

                checkerStore.setLastRedemptionNecessaryCheck(dateProvider(), tx: tx)

                return jobRecord
            }

            /// Now that we've enqueued the durable job, kick-start it.
            try await startRedemptionJobBlock(jobRecord)
        } else {
            logger.info("Subscription has not renewed since last redemption; bailing out!")

            await db.awaitableWrite { tx in
                checkerStore.setLastRedemptionNecessaryCheck(dateProvider(), tx: tx)
            }
        }
    }

    /// Let the server know that a client still cares about this subscriberId.
    private func performSubscriberIdHeartbeat(_ subscriberId: Data) async throws {
        let registerSubscriberIdResponse = try await networkManager.makePromise(
            request: OWSRequestFactory.setSubscriberID(subscriberId)
        ).awaitable()

        guard registerSubscriberIdResponse.responseStatusCode == 200 else {
            throw OWSAssertionError(
                "Unexpected status code registering new Backup subscriber ID! \(registerSubscriberIdResponse.responseStatusCode)",
                logger: logger
            )
        }
    }
}
