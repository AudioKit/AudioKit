//
//  AKFaderTests.swift
//  iOSTestSuiteTests
//
//  Created by Aurelius Prochazka on 4/2/20.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFaderTests: AKTestCase {

    func testDefault() {
        output = AKFader(input, gain: 1.0)
        AKTestNoEffect()
    }

    func testBypass() {
        let fader = AKFader(input, gain: 2.0)
        fader.bypass()
        output = fader
        AKTestNoEffect()
    }

    func testParameters() {
        output = AKFader(input, gain: 2.0)
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }

    func testParameters2() {
        output = AKFader(input, gain: 0.5)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }
}
