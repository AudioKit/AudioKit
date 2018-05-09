//
//  AKCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testAttackDuration() {
        output = AKCompressor(input, attackDuration: 0.1)
        AKTestMD5("3dfe38dc6ed21994dc6c14b91d83490b")
    }

    func testDefault() {
        output = AKCompressor(input)
        AKTestMD5("23be28244888d44bf98233e42d8df0f7")
    }

    func testHeadRoom() {
        output = AKCompressor(input, headRoom: 0)
        AKTestMD5("aeb15ce0bc17083e23269b8d811cb54d")
    }

    func testMasterGain() {
        output = AKCompressor(input, masterGain: 1)
        AKTestMD5("605c58df1139a4072b5bbb4d1fd23dc8")
    }

    func testParameters() {
        output = AKCompressor(input,
                              threshold: -25,
                              headRoom: 10,
                              attackDuration: 0.1,
                              releaseDuration: 0.1,
                              masterGain: 1)
        AKTestMD5("01d8b6f5527c23cf019b9f95d7ef860f")
    }

    // Release time is not currently tested

    func testThreshold() {
        output = AKCompressor(input, threshold: -25)
        AKTestMD5("4f58d7056622d0ba99f8579d286a3251")
    }

}
