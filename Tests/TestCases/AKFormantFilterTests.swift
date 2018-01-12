//
//  AKFormantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFormantFilterTests: AKTestCase {

    func testAttack() {
        output = AKFormantFilter(input, attackDuration: 0.234)
        AKTestMD5("3f80dc3e76e8265aef6348798bc7b3a1")
    }

    func testCenterFrequency() {
        output = AKFormantFilter(input, centerFrequency: 500)
        AKTestMD5("1b9e3e8a98cbb94692229353ace5de93")
    }

    func testDecay() {
        output = AKFormantFilter(input, decayDuration: 0.234)
        AKTestMD5("ff36210f7711bb8554a6431e2568460f")
    }

    func testDefault() {
        output = AKFormantFilter(input)
        AKTestMD5("108af8dc8247857aa4bbcb76881d9a70")
    }
}
