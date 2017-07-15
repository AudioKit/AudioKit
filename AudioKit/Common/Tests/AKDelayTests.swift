//
//  AKDelayTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKDelayTests: AKTestCase {

    func testParameters() {
        let input = AKOscillator()
        output = AKDelay(input, time: 0.0123, feedback: 0.345, lowPassCutoff: 1234, dryWetMix: 0.456)
        input.start()
        AKTestMD5("ff81a83a9a4335432029e8457a27cf6d")
    }

    func testTimeParameter() {
        let input = AKOscillator()
        output = AKDelay(input, time: 0.0123)
        input.start()
        AKTestMD5("d881533816a1a2fbbd507cbb9788f84e")
    }

    func testFeedbackParameter() {
        let input = AKOscillator()
        output = AKDelay(input, time: 0.0123, feedback: 0.345)
        input.start()
        AKTestMD5("a9056289ba3e2b693d410b2f35d2f1e2")
    }

    func testLowpassCutoffParameter() {
        let input = AKOscillator()
        output = AKDelay(input, time: 0.0123, lowPassCutoff: 1234)
        input.start()
        AKTestMD5("826cb9f7f2286fd078fd42ce055d3a8b")
    }

    func testDryWetMixParameter() {
        let input = AKOscillator()
        output = AKDelay(input, time: 0.0123, dryWetMix: 0.456)
        input.start()
        AKTestMD5("e92f43ca934cd0e63163e02149ad92ad")
    }
}
