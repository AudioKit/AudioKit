//
//  AKMorphingOscillatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/8/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKMorphingOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKMorphingOscillator()
        AKTestMD5("49b1b0f944c9ba307a890cb55cec75d6")
    }

    func testParametersSetOnInit() {
        output = AKMorphingOscillator(
            waveformArray: [AKTable(.sine), AKTable(.triangle), AKTable(.sawtooth), AKTable(.square)],
            frequency: 1_234,
            amplitude: 0.5,
            index: 1.234,
            detuningOffset: 1.234,
            detuningMultiplier: 1.234)

        AKTestMD5("626954fd45dd2d60e0879d73e0c9d7dd")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKMorphingOscillator(waveformArray: [AKTable(.sine), AKTable(.triangle), AKTable(.sawtooth), AKTable(.square)])
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.index = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.234
        output = oscillator
        AKTestMD5("626954fd45dd2d60e0879d73e0c9d7dd")
    }}
