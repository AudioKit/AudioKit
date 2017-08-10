//
//  AKBandRejectButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKBandRejectButterworthFilterTests: AKTestCase {

    func testDefault() {
        output = AKBandRejectButterworthFilter(input)
        AKTestMD5("15f5a0856974d5fd7e08a2a9304447d5")
    }

    func testParameters() {
        output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTestMD5("3d8544b345c1018f416a56ad4fca647c")
    }

    func testCenterFrequency() {
        output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500)
        AKTestMD5("a6d6903210e6fa26798f038e87fb331f")
    }

    func testBandwidth() {
        output = AKBandRejectButterworthFilter(input, bandwidth: 200)
        AKTestMD5("bc8fba1358fdddb0d067291feee8a6c6")
    }
}
