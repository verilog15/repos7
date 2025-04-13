//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import SignalServiceKit

extension DonateViewController {
    /// Represents the modes by which a user can donate in this view. Not to be
    /// confused with ``SignalServiceKit.DonationMode``.
    enum DonateMode: Int {
        case oneTime
        case monthly

        /// Converts the donation mode (one-time or monthly) for this view to
        /// the view-agnostic donation mode.
        var asDonationMode: SignalServiceKit.DonationMode {
            switch self {
            case .oneTime: return .oneTime
            case .monthly: return .monthly
            }
        }

        /// Converts the donation mode (one-time or monthly) for this view to
        /// the equivalent in the "choose payment method" sheet.
        ///
        /// We need this because this view supports one-time or monthly, but the
        /// sheet supports one-time, monthly, and gifting.
        var forChoosePaymentMethodSheet: DonateChoosePaymentMethodSheet.DonationMode {
            switch self {
            case .oneTime: return .oneTime
            case .monthly: return .monthly
            }
        }

        public var debugDescription: String {
            switch self {
            case .oneTime: return "one-time"
            case .monthly: return "monthly"
            }
        }
    }
}
