//
//  AKMorphingOscillatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/8/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKMorphingOscillatorTests: AKTestCase {

    let waveforms = [AKTable(.sine), AKTable(.triangle), AKTable(.sawtooth), AKTable(.square)]

    func testDefault() {
        output = AKMorphingOscillator()
        AKTestMD5("b3168bffcc63e44c6850fbf7c17ad98d")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKMorphingOscillator(waveformArray: waveforms)
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.index = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.234
        output = oscillator
        AKTestMD5("82c70357f013bc512ee48ea720187d3e")
    }

    func testParametersSetOnInit() {
        output = AKMorphingOscillator(waveformArray: waveforms,
                                      frequency: 1_234,
                                      amplitude: 0.5,
                                      index: 1.234,
                                      detuningOffset: 1.234,
                                      detuningMultiplier: 1.234)

        AKTestMD5("82c70357f013bc512ee48ea720187d3e")
    }
}
