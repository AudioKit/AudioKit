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
        let input = AKOscillator()
        output = AKBandPassButterworthFilter(input)
        input.start()
        AKTestMD5("574b9097eff0c33a2a04ae112fe19164")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKBandPassButterworthFilter(input, centerFrequency: 1500, bandwidth: 200)
        input.start()
        AKTestMD5("e1185c8d2a1772f989e5439320997ef3")
    }

    func testCenterFrequency() {
        let input = AKOscillator()
        output = AKBandPassButterworthFilter(input, centerFrequency: 1500)
        input.start()
        AKTestMD5("754a44acd72dc5c9c8cf35bb53e6e753")
    }

    func testBandwidth() {
        let input = AKOscillator()
        output = AKBandPassButterworthFilter(input, bandwidth: 200)
        input.start()
        AKTestMD5("48032ecc3ff8bc7dbd47cdfa77f561fd")
    }

}
