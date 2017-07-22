//
//  AKOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKOscillatorTests: AKTestCase {

    func testDefault() {
        output = input
        AKTestNoEffect()
    }

    func testParameters() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }

    func testFrequency() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400)
        output = input
        AKTestMD5("8fe098a1d2762bc664076a9ca7256762")
    }

    func testAmpitude() {
        input = AKOscillator(waveform: AKTable(.square), amplitude: 0.5)
        output = input
        AKTestMD5("45f2860b48e277b81c04d606874f3488")
    }

    func testParametersSetAfterInit() {
        input = AKOscillator(waveform: AKTable(.square))
        input.frequency = 400
        input.amplitude = 0.5
        output = input
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }
}
