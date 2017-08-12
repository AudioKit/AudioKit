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
        AKTestMD5("84d52429dc51254c90ba0ff58144e556")
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
        AKTestMD5("f2dde483d4c8fcdf4e38cce015c13a7e")
    }

    func testRatio() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5)
        AKTestMD5("48c9078961c0382a3f173dd19014c504")
    }

    func testReleaseTime() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5, releaseTime: 0.2)
        AKTestMD5("968fb7e517a411369ec8560115164a85")
    }

    func testThreshold() {
        input.amplitude = 2.0
        output = AKDynamicRangeCompressor(input, ratio: 0.5, threshold: -1)
        AKTestMD5("7460f203cac0a02297391b25906eff26")
    }

}
