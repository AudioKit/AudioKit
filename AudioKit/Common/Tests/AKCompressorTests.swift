//
//  AKCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKCompressor(input)
        AKTestMD5("ee2b005095e4583477cfa95157554b7a")
    }

    func testParameters() {
        output = AKCompressor(input,
                              threshold: -25,
                              headRoom: 10,
                              attackTime: 0.1,
                              releaseTime: 0.1,
                              masterGain: 1)
        AKTestMD5("3b5627770864e08796fff929b5444d1d")
    }

    func testThreshold() {
        output = AKCompressor(input, threshold: -25)
        AKTestMD5("f0880e74cc4140655806427fc2224258")
    }

    func testHeadRoom() {
        output = AKCompressor(input, headRoom: 0)
        AKTestMD5("92467b961b1dbc9b37f78bd4ed937add")
    }

    func testAttackTime() {
        output = AKCompressor(input, attackTime: 0.1)
        AKTestMD5("e830095751ba5d061b7761462f6fad12")
    }

    // Release time is not currently tested

    func testMasterGain() {
        output = AKCompressor(input, masterGain: 1)
        AKTestMD5("2b76f6283d951f245cc39230d3e9eb8c")
    }
}
