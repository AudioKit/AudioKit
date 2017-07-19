//
//  AKHighShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKHighShelfParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighShelfParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("907b6c2c83772318a8bee5abac56249c")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        input.start()
        AKTestMD5("9420c84d80db482b7bd2e981b0d53d33")
    }

    func testCenterFrequency() {
        let input = AKOscillator()
        output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500)
        input.start()
        AKTestMD5("5fb17e8c1053d4253252e11c593eab7a")
    }

    func testGain() {
        let input = AKOscillator()
        output = AKHighShelfParametricEqualizerFilter(input, gain: 2)
        input.start()
        AKTestMD5("26e22fd761898294c0dec2196df67c8f")
    }

    func testQ() {
        let input = AKOscillator()
        output = AKHighShelfParametricEqualizerFilter(input, q: 1.415)
        input.start()
        AKTestMD5("daea72b35b3418bda0e7196dc54a4e2f")
    }
}
