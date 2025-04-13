//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import LibSignalClient
import SignalServiceKit
import XCTest

final class ChatServiceAuthTest: XCTestCase {
    func testImplicit() {
        let auth = ChatServiceAuth.implicit()

        XCTAssertEqual(auth.credentials, .implicit)
    }

    func testExplicit() {
        let aciString = "125a6d22-5364-4583-9132-66227867d9ec"
        let aci = Aci.constantForTesting(aciString)

        let auth = ChatServiceAuth.explicit(aci: aci, deviceId: .primary, password: "foo bar")

        XCTAssertEqual(auth.credentials, .explicit(username: aciString, password: "foo bar"))
    }

    func testExplicitSecondaryDevice() {
        let aciString = "125a6d22-5364-4583-9132-66227867d9ec"
        let aci = Aci.constantForTesting(aciString)

        let auth = ChatServiceAuth.explicit(aci: aci, deviceId: DeviceId(validating: 3)!, password: "foo bar")

        XCTAssertEqual(auth.credentials, .explicit(username: "\(aciString).3", password: "foo bar"))
    }

    func testEquality() {
        let aci1 = Aci.randomForTesting()
        let aci2 = Aci.randomForTesting()

        let implicit = ChatServiceAuth.implicit()
        let explicit1 = ChatServiceAuth.explicit(aci: aci1, deviceId: .primary, password: "foo bar")
        let explicit2 = ChatServiceAuth.explicit(aci: aci1, deviceId: .primary, password: "foo bar")
        let explicit3 = ChatServiceAuth.explicit(aci: aci1, deviceId: .primary, password: "baz qux")
        let explicit4 = ChatServiceAuth.explicit(aci: aci2, deviceId: .primary, password: "foo bar")

        for auth in [implicit, explicit1, explicit2, explicit3, explicit4] {
            XCTAssertEqual(auth, auth)
        }

        for other in [explicit1, explicit2, explicit3, explicit4] {
            XCTAssertNotEqual(implicit, other)
            XCTAssertNotEqual(other, implicit)
        }

        XCTAssertEqual(explicit1, explicit2)
        XCTAssertNotEqual(explicit1, explicit3)
        XCTAssertNotEqual(explicit1, explicit4)
    }
}
