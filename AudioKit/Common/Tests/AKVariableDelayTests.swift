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
        AKTestMD5("48ea4c18ae98844bbbcd7fca368dc946")
    }

    func testParametersSetOnInit() {
        output = AKVariableDelay(input, time: 0.123_4, feedback: 0.95)
        AKTestMD5("9226df1559cc20cd4eeab47999ed9687")
    }

    func testParametersSetAfterInit() {
        let effect = AKVariableDelay(input)
        effect.time = 0.123_4
        effect.feedback = 0.95
        output = effect
        AKTestMD5("9226df1559cc20cd4eeab47999ed9687")
    }

    func testTime() {
        output = AKVariableDelay(input, time: 0.123_4)
        AKTestMD5("55da6c3d0aaac60e867dc5f3bbffb58a")
    }

    func testFeedback() {
        output = AKVariableDelay(input, feedback: 0.95)
        AKTestMD5("aba6459050d8369fa584f3fefe2d47c2")
    }

}
