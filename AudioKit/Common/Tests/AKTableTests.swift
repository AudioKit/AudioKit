//
//  AKTableTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 7/18/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKTableTests: AKTestCase {

    func testReverseSawtooth() {
        input = AKOscillator(waveform: AKTable(.reverseSawtooth))
        output = input
        AKTestMD5("5b4a1cdcd9864f80ad5163d7cbe3e01f")
    }

    func testSawtooth() {
        input = AKOscillator(waveform: AKTable(.sawtooth))
        output = input
        AKTestMD5("429344b732d20f8e8c89379bd75147a3")
    }

    func testSine() {
        input = AKOscillator(waveform: AKTable(.sine))
        output = input
        // This is just the usual tested sine wave
        AKTestNoEffect()
    }

    func testTriangle() {
        input = AKOscillator(waveform: AKTable(.triangle))
        output = input
        AKTestMD5("c533c2b5975c4817d1c54f5821779a8f")
    }

}
