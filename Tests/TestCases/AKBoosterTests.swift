//
//  AKBoosterTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBoosterTests: AKTestCase {

    func testDefault() {
        output = AKBooster(input)
        AKTestNoEffect()
    }

    func testParameters() {
        output = AKBooster(input, gain: 2.0)
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }

    func testParameters2() {
        output = AKBooster(input, gain: 0.5)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }
}
