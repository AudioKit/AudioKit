//
//  AKPWMOscillatorTests.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/6/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPWMOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKPWMOscillator()
        AKTestMD5("32911323b68d88bd7d47ed97c1e953b4")
    }

    func testParameters() {
        output = AKPWMOscillator(frequency: 1_234,
                                 amplitude: 0.5,
                                 pulseWidth: 0.75,
                                 detuningOffset: 1.234,
                                 detuningMultiplier: 1.234)
        AKTestMD5("c6900108acaf6ecba12409938715ea75")
    }

    func testFrequency() {
        output = AKPWMOscillator(frequency: 1_234)
        AKTestMD5("f6a4dac2c8ce13e709c5bfe77c7d4eaf")
    }

    func testAmplitude() {
        output = AKPWMOscillator(frequency: 1_234, amplitude: 0.5)
        AKTestMD5("0ba0ff847a04a46f68ddcd0f5fc65356")
    }

    func testPulseWidth() {
        output = AKPWMOscillator(frequency: 1_234, pulseWidth: 0.75)
        AKTestMD5("3e936c8b0afb3cd5fc05b8ded180951f")
    }

    func testDetuningOffset() {
        output = AKPWMOscillator(frequency: 1_234, detuningOffset: 1.234)
        AKTestMD5("a23a87d81ac1a3352537b2e91c80ffa8")
    }

    func testDetuningMultiplier() {
        output = AKPWMOscillator(frequency: 1_234, detuningMultiplier: 1.234)
        AKTestMD5("133d7d153c3e42a42cebfcb4b89c714b")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKPWMOscillator()
        oscillator.frequency = 1_234
        oscillator.amplitude = 0.5
        oscillator.pulseWidth = 0.75
        oscillator.detuningOffset = 1.234
        oscillator.detuningMultiplier = 1.234
        output = oscillator
        AKTestMD5("c6900108acaf6ecba12409938715ea75")
    }}
