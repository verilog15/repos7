//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import XCTest
@testable import SignalServiceKit

class SubscriptionChargeFailureTest: XCTestCase {
    typealias ChargeFailure = Subscription.ChargeFailure

    func testJsonInit() {
        let chargeFailure = ChargeFailure(jsonDictionary: ["code": "foo"])
        XCTAssertEqual(chargeFailure.code, "foo")

        let strangeInputs: [[String: Any]] = [[:], ["no code": "missing"], ["code": 123]]
        for jsonDictionary in strangeInputs {
            let chargeFailure = ChargeFailure(jsonDictionary: jsonDictionary)
            XCTAssertNil(chargeFailure.code)
        }
    }
}

class SubscriptionTest: XCTestCase {
    let subscriptionDict: [String: Any] = {
        let endOfCurrentPeriodRawValue: Double = 1618881836
        let billingCycleAnchorRawValue: Double = 1587345836
        return [
            "level": 123,
            "currency": "USD",
            "amount": 500,
            "endOfCurrentPeriod": endOfCurrentPeriodRawValue,
            "billingCycleAnchor": billingCycleAnchorRawValue,
            "active": true,
            "cancelAtPeriodEnd": false,
            "status": "active",
            "processor": "STRIPE",
            "paymentMethod": "CARD",
            "paymentProcessing": false
        ]
    }()

    func testJsonInit() throws {
        let subscription = try Subscription(subscriptionDict: subscriptionDict,
                                            chargeFailureDict: nil)

        XCTAssertEqual(subscription.level, 123)
        XCTAssertEqual(subscription.amount, FiatMoney(currencyCode: "USD", value: 5))
        XCTAssertEqual(subscription.endOfCurrentPeriod, 1618881836)
        XCTAssertEqual(subscription.billingCycleAnchor, 1587345836)
        XCTAssertTrue(subscription.active)
        XCTAssertFalse(subscription.cancelAtEndOfPeriod)
        XCTAssertEqual(subscription.status, .active)
        XCTAssertNil(subscription.chargeFailure)
    }

    func testJsonInitWithUnexpectedStatus() throws {
        var subscriptionDictWithUnexpectedStatus = subscriptionDict
        subscriptionDictWithUnexpectedStatus["status"] = "unexpected!!"

        let subscription = try Subscription(subscriptionDict: subscriptionDictWithUnexpectedStatus,
                                            chargeFailureDict: nil)

        XCTAssertEqual(subscription.status, .unknown)
        XCTAssertNil(subscription.chargeFailure)
    }

    func testChargeFailure() throws {
        let subscription = try Subscription(subscriptionDict: subscriptionDict,
                                            chargeFailureDict: ["code": "foo bar"])
        XCTAssertEqual(subscription.chargeFailure?.code, "foo bar")

        let strangeChargeFailures: [[String: Any]] = [[:], ["no code": "missing"], ["code": 123]]
        for chargeFailureDict in strangeChargeFailures {
            let subscription = try Subscription(subscriptionDict: subscriptionDict,
                                                chargeFailureDict: chargeFailureDict)
            XCTAssertNotNil(subscription.chargeFailure)
            XCTAssertNil(subscription.chargeFailure?.code)
        }
    }
}

class BadgeIdsTest: XCTestCase {
    func testSubscriptionContains() {
        let testCases: [(String, Bool)] = [
            ("R_LOW", true),
            ("R_MED", true),
            ("R_HIGH", true),
            ("BOOST", false),
            ("GIFT", false),
            ("OTHER", false),
            ("", false)
        ]
        for (badgeId, shouldMatch) in testCases {
            XCTAssertEqual(SubscriptionBadgeIds.contains(badgeId), shouldMatch, "\(badgeId)")
        }
    }

    func testBoostContains() {
        let testCases: [(String, Bool)] = [
            ("R_LOW", false),
            ("R_MED", false),
            ("R_HIGH", false),
            ("BOOST", true),
            ("GIFT", false),
            ("OTHER", false),
            ("", false)
        ]
        for (badgeId, shouldMatch) in testCases {
            XCTAssertEqual(BoostBadgeIds.contains(badgeId), shouldMatch, "\(badgeId)")
        }
    }
}

class SubscriptionManagerDonationConfigurationTest: XCTestCase {
    private typealias JSON = [String: Any]
    private typealias DonationConfiguration = DonationSubscriptionManager.DonationConfiguration

    private enum CurrencyFixtures {
        static let minimumAmount: Int = 5

        static let giftPresetAmount: Int = 10
        static let boostPresetAmounts: [Int] = [1, 2, 3]
        static let levelOneAmount: Int = 5
        static let levelTwoAmount: Int = 5

        static let supportedPaymentMethods: [String] = ["CARD", "PAYPAL"]

        static func withDefaultValues(
            minimumAmount: Int = minimumAmount,
            giftLevel: UInt? = LevelFixtures.giftLevel,
            giftPresetAmount: Int = giftPresetAmount,
            boostLevel: UInt? = LevelFixtures.boostLevel,
            boostPresetAmounts: [Int] = boostPresetAmounts,
            levelOne: UInt? = LevelFixtures.levelOne,
            levelOneAmount: Int = levelOneAmount,
            levelTwo: UInt? = LevelFixtures.levelTwo,
            levelTwoAmount: Int = levelTwoAmount,
            supportedPaymentMethods: [String] = supportedPaymentMethods
        ) -> JSON {
            var result: JSON = [
                "minimum": minimumAmount,
                "supportedPaymentMethods": supportedPaymentMethods
            ]

            result["oneTime"] = { () -> [String: [Int]] in
                var oneTimeLevels = [String: [Int]]()

                if let giftLevel {
                    oneTimeLevels["\(giftLevel)"] = [giftPresetAmount]
                }

                if let boostLevel {
                    oneTimeLevels["\(boostLevel)"] = boostPresetAmounts
                }

                return oneTimeLevels
            }()

            result["subscription"] = { () -> [String: Int] in
                var subscriptionLevels = [String: Int]()

                if let levelOne {
                    subscriptionLevels["\(levelOne)"] = levelOneAmount
                }

                if let levelTwo {
                    subscriptionLevels["\(levelTwo)"] = levelTwoAmount
                }

                return subscriptionLevels
            }()

            return result
        }
    }

    private enum LevelFixtures {
        private static let badgeJson: JSON = [
            "id": "test-badge-1",
            "category": "donor",
            "name": "Test Badge 1",
            "description": "First test badge",
            "sprites6": ["ldpi.png", "mdpi.png", "hdpi.png", "xhdpi.png", "xxhdpi.png", "xxxhdpi.png"]
        ]

        static let badge: ProfileBadge = try! .init(jsonDictionary: badgeJson)

        static let giftLevel: UInt = 100
        static let boostLevel: UInt = 1
        static let levelOne: UInt = 500
        static let levelTwo: UInt = 1000

        static func withDefaultValues(
            levels: [UInt] = [
                giftLevel,
                boostLevel,
                levelOne,
                levelTwo
            ]
        ) -> JSON {
            levels.reduce(into: [:]) { partialResult, level in
                partialResult["\(level)"] = [
                    "badge": badgeJson
                ]
            }
        }
    }

    private enum DonationConfigurationFixtures {
        static func withDefaultValues(
            currenciesJson: JSON = CurrencyFixtures.withDefaultValues(),
            levelsJson: JSON = LevelFixtures.withDefaultValues()
        ) -> JSON {
            [
                "sepaMaximumEuros": 10000,
                "currencies": [
                    "usd": currenciesJson
                ],
                "levels": levelsJson
            ]
        }
    }

    private func keyedToUSD<T>(t: T) -> [Currency.Code: T] {
        ["USD": t]
    }

    func testParseValidDonationConfig() throws {
        let config = try DonationConfiguration.from(
            configurationServiceResponse: DonationConfigurationFixtures.withDefaultValues()
        )

        XCTAssertEqual(config.boost.level, LevelFixtures.boostLevel)
        XCTAssertEqual(config.boost.badge, LevelFixtures.badge)
        XCTAssertEqual(config.boost.minimumAmountsByCurrency.usd, CurrencyFixtures.minimumAmount.asUsd)
        XCTAssertEqual(config.boost.presetAmounts.usd.amounts, CurrencyFixtures.boostPresetAmounts.map { $0.asUsd })

        XCTAssertEqual(config.gift.level, LevelFixtures.giftLevel)
        XCTAssertEqual(config.gift.badge, LevelFixtures.badge)
        XCTAssertEqual(config.gift.presetAmount.usd, CurrencyFixtures.giftPresetAmount.asUsd)

        let firstSubscriptionLevel = config.subscription.levels.first!
        XCTAssertEqual(firstSubscriptionLevel.level, LevelFixtures.levelOne)
        XCTAssertEqual(firstSubscriptionLevel.badge, LevelFixtures.badge)
        XCTAssertEqual(firstSubscriptionLevel.amounts.usd, CurrencyFixtures.levelOneAmount.asUsd)

        let secondSubscriptionLevel = config.subscription.levels.last!
        XCTAssertEqual(secondSubscriptionLevel.level, LevelFixtures.levelTwo)
        XCTAssertEqual(secondSubscriptionLevel.badge, LevelFixtures.badge)
        XCTAssertEqual(secondSubscriptionLevel.amounts.usd, CurrencyFixtures.levelTwoAmount.asUsd)

        XCTAssertEqual(config.paymentMethods.supportedPaymentMethods(forCurrencyCode: "USD"), [.paypal, .applePay, .creditOrDebitCard])
    }

    func testParseConfigMissingThings() {
        let missingBoost = DonationConfigurationFixtures.withDefaultValues(
            levelsJson: LevelFixtures.withDefaultValues(
                levels: [LevelFixtures.giftLevel, LevelFixtures.levelOne, LevelFixtures.levelTwo]
            )
        )

        let missingGift = DonationConfigurationFixtures.withDefaultValues(
            levelsJson: LevelFixtures.withDefaultValues(
                levels: [LevelFixtures.boostLevel, LevelFixtures.levelOne, LevelFixtures.levelTwo]
            )
        )

        let missingBoostLevel = DonationConfigurationFixtures.withDefaultValues(
            currenciesJson: CurrencyFixtures.withDefaultValues(
                boostLevel: nil
            )
        )

        let missingGiftLevel = DonationConfigurationFixtures.withDefaultValues(
            currenciesJson: CurrencyFixtures.withDefaultValues(
                giftLevel: nil
            )
        )

        let missingSubscriptionLevel = DonationConfigurationFixtures.withDefaultValues(
            currenciesJson: CurrencyFixtures.withDefaultValues(
                levelOne: nil
            )
        )

        expect(
            try DonationConfiguration.from(configurationServiceResponse: missingBoost),
            throwsParseError: .missingBoostBadge
        )
        expect(
            try DonationConfiguration.from(configurationServiceResponse: missingGift),
            throwsParseError: .missingGiftBadge
        )
        expect(
            try DonationConfiguration.from(configurationServiceResponse: missingBoostLevel),
            throwsParseError: .missingBoostPresetAmounts
        )
        expect(
            try DonationConfiguration.from(configurationServiceResponse: missingGiftLevel),
            throwsParseError: .missingGiftPresetAmount
        )
        expect(
            try DonationConfiguration.from(configurationServiceResponse: missingSubscriptionLevel),
            throwsParseError: .missingAmountForLevel(LevelFixtures.levelOne)
        )
    }

    func testParseConfigWithUnrecognizedPaymentMethod() throws {
        let unexpectedPaymentMethod = DonationConfigurationFixtures.withDefaultValues(
            currenciesJson: CurrencyFixtures.withDefaultValues(
                supportedPaymentMethods: CurrencyFixtures.supportedPaymentMethods + ["cash money"]
            )
        )

        _ = try DonationConfiguration.from(configurationServiceResponse: unexpectedPaymentMethod)
    }

    // MARK: Utilities

    private func expect(
        _ expression: @autoclosure () throws -> DonationConfiguration,
        throwsParseError expectedParseError: DonationConfiguration.ParseError
    ) {
        do {
            let config = try expression()
            XCTFail("Unexpectedly parsed successfully: \(config)")
        } catch let error {
            if
                let parseError = error as? DonationConfiguration.ParseError,
                expectedParseError == parseError
            {
                return
            }

            XCTFail("Threw unexpected error: \(error)")
        }
    }
}

private extension Dictionary where Key == Currency.Code {
    var usd: Value {
        self["USD"]!
    }
}

private extension Int {
    var asUsd: FiatMoney {
        .init(currencyCode: "USD", value: Decimal(self))
    }
}
