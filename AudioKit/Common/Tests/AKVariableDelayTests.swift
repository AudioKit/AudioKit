//
//  AKVariableDelayTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKVariableDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 5.0 // needs to be this long since the default time is one second
    }

    func testDefault() {
        output = AKVariableDelay(input)
        AKTestMD5("4f6ff617850190542e120c2e27cdde54")
    }

    func testFeedback() {
        output = AKVariableDelay(input, feedback: 0.95)
        AKTestMD5("f041e3cf613921e41f8212fc7012ed6f")
    }

    func testParametersSetAfterInit() {
        let effect = AKVariableDelay(input)
        effect.time = 0.123_4
        effect.feedback = 0.95
        output = effect
        AKTestMD5("5024a7ef59a303c6f7a6fbebf0486d5e")
    }

    func testParametersSetOnInit() {
        output = AKVariableDelay(input, time: 0.123_4, feedback: 0.95)
        AKTestMD5("5024a7ef59a303c6f7a6fbebf0486d5e")
    }

    func testTime() {
        output = AKVariableDelay(input, time: 0.123_4)
        AKTestMD5("db7ec67b9dba22da741bfe607b77fd68")
    }

}
