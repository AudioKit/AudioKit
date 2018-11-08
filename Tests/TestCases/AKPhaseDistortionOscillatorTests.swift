//
//  AKPhaseDistortionOscillatorTests.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPhaseDistortionOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKPhaseDistortionOscillator()
        AKTestMD5("9bb6df5a3b0bd5587b19e6acf8f6943d")
    }

    func testParameters() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square),
                                             frequency: 1_234,
                                             amplitude: 0.5,
                                             phaseDistortion: 1.234,
                                             detuningOffset: 1.234,
                                             detuningMultiplier: 1.234)
        AKTestMD5("664e9b50ff633d1bb6bd8e173bec09e3")
    }

    func testFrequency() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square), frequency: 1_234)
        AKTestMD5("095709fff34023e66b3f27e2f97d6dbd")
    }

    func testAmplitude() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square), amplitude: 0.5)
        AKTestMD5("4eeefb56d24b9ad39ec824e34acdcd55")
    }

    func testPhaseDistortion() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square), phaseDistortion: 1.234)
        AKTestMD5("066f3baeb08af73a5d9ae909a7b43a4e")
    }

    func testDetuningOffset() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square), detuningOffset: 1.234)
        AKTestMD5("a63567f271a6d1d5d6b2ba22e80d64ca")
    }

    func testDetuningMultiplier() {
        output = AKPhaseDistortionOscillator(waveform: AKTable(.square), detuningMultiplier: 1.234)
        AKTestMD5("41332aab84da42575572efa17fc040c2")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.square))
        oscillator.rampDuration = 0.0
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.phaseDistortion = 1.234
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.234
        output = oscillator
        AKTestMD5("664e9b50ff633d1bb6bd8e173bec09e3")
    }
}
