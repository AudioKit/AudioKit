//
//  AKPeakingParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPeakingParametricEqualizerFilterTests: AKTestCase {

    func testCenterFrequency() {
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500)
        AKTestMD5("a541c9bca732bf16b662720bba0c4f92")
    }

    func testDefault() {
        output = AKPeakingParametricEqualizerFilter(input)
        AKTestMD5("9e4ed2b0de91979bc0db2fc390bee945")
    }

    func testGain() {
        output = AKPeakingParametricEqualizerFilter(input, gain: 2)
        AKTestMD5("7fb1bd650162fa83b50cc0f26ba65e5c")
    }

    func testParameters() {
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTestMD5("490256c941007f13200b95e8d9046415")
    }

    func testQ() {
        output = AKPeakingParametricEqualizerFilter(input, q: 1.415)
        AKTestMD5("6661b6f2b2fda4bcdf8fb6e56c1b120f")
    }
}
