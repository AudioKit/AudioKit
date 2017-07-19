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
        let input = AKOscillator(waveform: AKTable(.reverseSawtooth))
        output = input
        input.start()
        AKTestMD5("fd7c1678c919f8b6a1949f8ffb6a11f9")
    }

    func testSawtooth() {
        let input = AKOscillator(waveform: AKTable(.sawtooth))
        output = input
        input.start()
        AKTestMD5("f391c99c2673ac2fde49b5310a230416")
    }

    func testSine() {
        let input = AKOscillator(waveform: AKTable(.sine))
        output = input
        input.start()
        // This is just the usual tested sine wave
        AKTestNoEffect()
    }

    func testTriangle() {
        let input = AKOscillator(waveform: AKTable(.triangle))
        output = input
        input.start()
        AKTestMD5("c8069e19df9a82e3c4dc5811c55bc73c")
    }


}
