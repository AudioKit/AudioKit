//
//  AKFMOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKFMOscillatorTests: AKTestCase {
    
    func testDefault() {
        output = AKFMOscillator()
        AKTestMD5("362f9f2f10f025ec8c798713e2bf6a2e")
    }
    
    func testSquareWave() {
        output = AKFMOscillator(waveform: AKTable(.Square, size: 4096))
        AKTestMD5("c6b194d7bf925ade38c3a1d5333326f8")
    }
    
    func testParametersSetOnInit() {
        output = AKFMOscillator(waveform: AKTable(.Square),
                                baseFrequency: 1234,
                                carrierMultiplier: 1.234,
                                modulatingMultiplier: 1.234,
                                modulationIndex: 1.234,
                                amplitude: 0.5)
        AKTestMD5("9d4ba935daab84b999de48fd9314d3ae")
    }
    
    func testParametersSetAfterInit() {
        let oscillator = AKFMOscillator(waveform: AKTable(.Square))
        oscillator.baseFrequency        = 1234
        oscillator.carrierMultiplier    = 1.234
        oscillator.modulatingMultiplier = 1.234
        oscillator.modulationIndex      = 1.234
        oscillator.amplitude            = 0.5
        output = oscillator
        AKTestMD5("9d4ba935daab84b999de48fd9314d3ae")
    }
}
