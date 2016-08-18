//
//  AKPWMOscillatorTests.swift
//  AudioKit for iOS
//
//  Created by Aurelius Prochazka on 8/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKPWMOscillatorTests: AKTestCase {
    
    func testDefault() {
        output = AKPWMOscillator()
        AKTestMD5("32911323b68d88bd7d47ed97c1e953b4")
    }
    
    func testParametersSetOnInit() {
        output = AKPWMOscillator(frequency: 1234,
                                 amplitude: 0.5,
                                 pulseWidth: 0.75,
                                 detuningOffset: 1.234,
                                 detuningMultiplier: 1.234)
        AKTestMD5("c6900108acaf6ecba12409938715ea75")
    }
    
    func testParametersSetAfterInit() {
        let oscillator = AKPWMOscillator()
        oscillator.frequency          = 1234
        oscillator.amplitude          = 0.5
        oscillator.pulseWidth         = 0.75
        oscillator.detuningOffset     = 1.234
        oscillator.detuningMultiplier = 1.234
        output = oscillator
        AKTestMD5("c6900108acaf6ecba12409938715ea75")
    }}
