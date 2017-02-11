//
//  AKPhaseDistortionOscillatorTests.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKPhaseDistortionOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKPhaseDistortionOscillator()
        AKTestMD5("9bb6df5a3b0bd5587b19e6acf8f6943d")
    }

    func testParametersSetOnInit() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square),
                                             frequency: 1_234,
                                             amplitude: 0.5,
                                             phaseDistortion: 1.234,
                                             detuningOffset: 1.234,
                                             detuningMultiplier: 1.234)
        AKTestMD5("664e9b50ff633d1bb6bd8e173bec09e3")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square))
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.phaseDistortion = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.234
        output = oscillator
        AKTestMD5("664e9b50ff633d1bb6bd8e173bec09e3")
    }}
