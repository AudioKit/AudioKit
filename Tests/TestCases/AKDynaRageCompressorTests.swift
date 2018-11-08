//
//  AKDynaRangeCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKDynaRangeCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
        input.rampDuration = 0.0
        input.amplitude = 0.1
    }

    func testAttackTime() {
        output = AKDynaRageCompressor(input, ratio: 10, attackTime: 21)
        AKTestMD5("27de5d9f687d6c114126e2e243b22a25")
    }

    func testDefault() {
        output = AKDynaRageCompressor(input)
        AKTestMD5("0ae621119d307784c6c9daa2be88115c")
    }

    func testParameters() {
        output = AKDynaRageCompressor(input,
                                      ratio: 10,
                                      threshold: -1,
                                      attackTime: 21,
                                      releaseTime: 22)
        AKTestMD5("746a16c29c92b779e3b6e05d636cdf53")
    }

    func testRage() {
        output = AKDynaRageCompressor(input, ratio: 10, rage: 10)
        AKTestMD5("d86e371b09429c9636ffdb260958e35b")
    }

    func testRatio() {
        output = AKDynaRageCompressor(input, ratio: 10)
        AKTestMD5("d86e371b09429c9636ffdb260958e35b")
    }

    func testReleaseTime() {
        output = AKDynaRageCompressor(input, ratio: 10, releaseTime: 22)
        AKTestMD5("00ad8e2278e31838555163547d9cac9c")
    }

    func testThreshold() {
        output = AKDynaRageCompressor(input, ratio: 10, threshold: -1)
        AKTestMD5("85583edfafd159d2955f6a2d51481bee")
    }

}
