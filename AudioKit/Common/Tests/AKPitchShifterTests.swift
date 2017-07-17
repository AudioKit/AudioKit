//
//  AKPitchShifterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPitchShifterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPitchShifter(input)
        input.start()
        AKTestMD5("c49a3cb36261a3e8e45a59b90899628c")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKPitchShifter(input, shift: 7, windowSize: 2048, crossfade: 1024)
        input.start()
        AKTestMD5("cc5745def2343c7d1b37c7371ce79a81")
    }

    func testShift() {
        let input = AKOscillator()
        output = AKPitchShifter(input, shift: 7)
        input.start()
        AKTestMD5("9bf85eb60c78803e8417281b24af7251")
    }

    func testWindowSize() {
        let input = AKOscillator()
        output = AKPitchShifter(input, shift: 7, windowSize: 2048)
        input.start()
        AKTestMD5("6cc09d4840bd6aaca5ec70385e470158")
    }

    func testCrossfade() {
        let input = AKOscillator()
        output = AKPitchShifter(input, shift: 7, crossfade: 1024)
        input.start()
        AKTestMD5("f757f7f66ca27d5d5f30b435423f7eda")
    }

}
