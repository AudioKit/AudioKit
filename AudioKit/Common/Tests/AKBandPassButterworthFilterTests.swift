//
//  AKBandPassButterworthFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKBandPassButterworthFilterTests: AKTestCase {

    func testDefault() {
        output = AKBandPassButterworthFilter(input)
        AKTestMD5("574b9097eff0c33a2a04ae112fe19164")
    }

    func testParameters() {
        output = AKBandPassButterworthFilter(input, centerFrequency: 1500, bandwidth: 200)
        AKTestMD5("e1185c8d2a1772f989e5439320997ef3")
    }

    func testCenterFrequency() {
        output = AKBandPassButterworthFilter(input, centerFrequency: 1500)
        AKTestMD5("754a44acd72dc5c9c8cf35bb53e6e753")
    }

    func testBandwidth() {
        output = AKBandPassButterworthFilter(input, bandwidth: 200)
        AKTestMD5("48032ecc3ff8bc7dbd47cdfa77f561fd")
    }

}
