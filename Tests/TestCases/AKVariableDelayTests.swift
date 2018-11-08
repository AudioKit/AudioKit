//
//  AKVariableDelayTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
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
        AKTestMD5("c70cd955bd783b4f84b497d00ed1b9f7")
    }

    func testFeedback() {
        output = AKVariableDelay(input, feedback: 0.95)
        AKTestMD5("58250ab52957d2aa3d9efca9ed10cf88")
    }

    func testParametersSetAfterInit() {
        let effect = AKVariableDelay(input)
        effect.rampDuration = 0.0
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
