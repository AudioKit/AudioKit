//
//  AKFMOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKFMOscillatorTests: AKTestCase {
    
    func testDefault() {
        output = AKFMOscillator()
        AKTestMD5("c4b8544dc178c161c11b19cc4cafc08f")
    }
    
    func testSquareWave() {
        output = AKFMOscillator(waveform: AKTable(.square, size: 4096))
        AKTestMD5("c6b194d7bf925ade38c3a1d5333326f8")
    }
    
    func testParametersSetOnInit() {
        output = AKFMOscillator(waveform: AKTable(.square),
                                baseFrequency: 1234,
                                carrierMultiplier: 1.234,
                                modulatingMultiplier: 1.234,
                                modulationIndex: 1.234,
                                amplitude: 0.5)
        AKTestMD5("9d4ba935daab84b999de48fd9314d3ae")
    }
    
    func testParametersSetAfterInit() {
        let oscillator = AKFMOscillator(waveform: AKTable(.square))
        oscillator.baseFrequency        = 1234
        oscillator.carrierMultiplier    = 1.234
        oscillator.modulatingMultiplier = 1.234
        oscillator.modulationIndex      = 1.234
        oscillator.amplitude            = 0.5
        output = oscillator
        AKTestMD5("9d4ba935daab84b999de48fd9314d3ae")
    }
    
    func testPresetStunRay() {
        let preset = AKFMOscillator()
        preset.presetStunRay()
        output = preset
        AKTestMD5("1a42a14c345ca10b6a20c333d9fea936")
    }
    
    func testPresetFogHorn() {
        let preset = AKFMOscillator()
        preset.presetFogHorn()
        output = preset
        AKTestMD5("d34da68224e9eac50c756cee1d43a8ac")
    }
    
    func testPresetBuzzer() {
        let preset = AKFMOscillator()
        preset.presetBuzzer()
        output = preset
        AKTestMD5("6ad8e692ca2a215ca2acd71151c9a201")
    }
    
    func testPresetSpiral() {
        let preset = AKFMOscillator()
        preset.presetSpiral()
        output = preset
        AKTestMD5("558fc4d8d97e8644188b7e03c91eb235")
    }
    
    func testPresetWobble() {
        let preset = AKFMOscillator()
        preset.presetWobble()
        output = preset
        AKTestMD5("cabe5773a5912ac40b2ec4bd7cee16bd")
    }

}
