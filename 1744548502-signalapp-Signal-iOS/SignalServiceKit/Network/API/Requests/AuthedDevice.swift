//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

public enum AuthedDevice {
    case implicit
    case explicit(Explicit)

    public struct Explicit {
        public let aci: Aci
        public let phoneNumber: E164
        public let pni: Pni
        public let deviceId: DeviceId
        public var isPrimaryDevice: Bool { deviceId == .primary }
        public let authPassword: String

        public init(aci: Aci, phoneNumber: E164, pni: Pni, deviceId: DeviceId, authPassword: String) {
            self.aci = aci
            self.phoneNumber = phoneNumber
            self.pni = pni
            self.deviceId = deviceId
            self.authPassword = authPassword
        }

        public var localIdentifiers: LocalIdentifiers {
            return LocalIdentifiers(aci: aci, pni: pni, e164: phoneNumber)
        }

        public var authedAccount: AuthedAccount.Explicit {
            return .init(
                aci: aci,
                pni: pni,
                e164: phoneNumber,
                deviceId: deviceId,
                authPassword: authPassword
            )
        }
    }

    public func orIfImplicitUse(_ other: Self) -> Self {
        switch self {
        case .explicit:
            return self
        case .implicit:
            return other
        }
    }

    public var authedAccount: AuthedAccount {
        switch self {
        case .implicit:
            return .implicit()
        case .explicit(let explicit):
            return .explicit(
                aci: explicit.aci,
                pni: explicit.pni,
                e164: explicit.phoneNumber,
                deviceId: explicit.deviceId,
                authPassword: explicit.authPassword
            )
        }
    }
}
