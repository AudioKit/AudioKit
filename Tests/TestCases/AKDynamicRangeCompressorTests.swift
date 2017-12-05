//
//  AKDynamicRangeCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 7/14/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKDynamicRangeCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
    }

    func testAttackTime() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5, attackTime: 0.2)
        AKTestMD5("27de5d9f687d6c114126e2e243b22a25")
    }

    func testDefault() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input)
        AKTestMD5("0ae621119d307784c6c9daa2be88115c")
    }

    func testParameters() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input,
                                          ratio: 0.5,
                                          threshold: -1,
                                          attackTime: 0.2,
                                          releaseTime: 0.2)
        AKTestMD5("746a16c29c92b779e3b6e05d636cdf53")
    }

    func testRatio() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5)
        AKTestMD5("d86e371b09429c9636ffdb260958e35b")
    }

    func testReleaseTime() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5, releaseTime: 0.2)
        AKTestMD5("00ad8e2278e31838555163547d9cac9c")
    }

    func testThreshold() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5, threshold: -1)
        AKTestMD5("85583edfafd159d2955f6a2d51481bee")
    }

}
