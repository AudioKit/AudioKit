//
//  AKBandPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBandPassButterworthFilterTests: AKTestCase {

    func testBandwidth() {
        output = AKBandPassButterworthFilter(input, bandwidth: 200)
        AKTestMD5("732a11b4fbbb8b66dd5ee1552fcb0395")
    }

    func testCenterFrequency() {
        output = AKBandPassButterworthFilter(input, centerFrequency: 1_500)
        AKTestMD5("472bdb00a02bcc2ac0dc25a1b4d2c46d")
    }

    func testDefault() {
        output = AKBandPassButterworthFilter(input)
        AKTestMD5("1645b5761fe4635599c4cb0b69aa6c87")
    }

    func testParameters() {
        output = AKBandPassButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTestMD5("fa55dae0efb8079dca1767da97591301")
    }

}
