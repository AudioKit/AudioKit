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

    func testDefault() {
        output = AKPeakingParametricEqualizerFilter(input)
        AKTestMD5("d1003d6785e625834b6c9772a32017ee")
    }

    func testParameters() {
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTestMD5("c5366c3dc9ff5d5c537a3e11559833e3")
    }

    func testCenterFrequency() {
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500)
        AKTestMD5("20dcdb74b4f4ae3b76a200ac806bbb51")
    }

    func testGain() {
        output = AKPeakingParametricEqualizerFilter(input, gain: 2)
        AKTestMD5("77ac53e71064e3d1131b2255652cf9b0")
    }

    func testQ() {
        output = AKPeakingParametricEqualizerFilter(input, q: 1.415)
        AKTestMD5("0f99832ccebc4975f820598d23a6f3d9")
    }
}
