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
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("d1003d6785e625834b6c9772a32017ee")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        input.start()
        AKTestMD5("c5366c3dc9ff5d5c537a3e11559833e3")
    }

    func testCenterFrequency() {
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500)
        input.start()
        AKTestMD5("20dcdb74b4f4ae3b76a200ac806bbb51")
    }

    func testGain() {
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input, gain: 2)
        input.start()
        AKTestMD5("77ac53e71064e3d1131b2255652cf9b0")
    }

    func testQ() {
        let input = AKOscillator()
        output = AKPeakingParametricEqualizerFilter(input, q: 1.415)
        input.start()
        AKTestMD5("0f99832ccebc4975f820598d23a6f3d9")
    }
}
