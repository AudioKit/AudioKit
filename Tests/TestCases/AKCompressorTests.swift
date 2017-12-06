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

    func testAttackTime() {
        output = AKCompressor(input, attackTime: 0.1)
        AKTestMD5("6845eab70c0b672ace59845cb28c404e")
    }

    func testDefault() {
        output = AKCompressor(input)
        AKTestMD5("4a0832f24a7096bd9384a76f8bd9db01")
    }

    func testHeadRoom() {
        output = AKCompressor(input, headRoom: 0)
        AKTestMD5("2bd03fd22113e7df4ff3e610aac1f3a1")
    }

    func testMasterGain() {
        output = AKCompressor(input, masterGain: 1)
        AKTestMD5("28f9437589641f6ab28c8e989e9444d0")
    }

    func testParameters() {
        output = AKCompressor(input,
                              threshold: -25,
                              headRoom: 10,
                              attackTime: 0.1,
                              releaseTime: 0.1,
                              masterGain: 1)
        AKTestMD5("b5ce91252b050c6875b07232bae29a93")
    }

    // Release time is not currently tested

    func testThreshold() {
        output = AKCompressor(input, threshold: -25)
        AKTestMD5("3d3d402e24582ac17f47c72e8315fffb")
    }

}
