//
//  AKFMOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKFMOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKFMOscillator()
        AKTestMD5("3fee66d7da663b3e68142de923962819")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKFMOscillator(waveform: AKTable(.square))
        oscillator.baseFrequency = 1_234
        oscillator.carrierMultiplier = 1.234
        oscillator.modulatingMultiplier = 1.234
        oscillator.modulationIndex = 1.234
        oscillator.amplitude = 0.5
        output = oscillator
        AKTestMD5("8387b7242dbb91c0a1f397a9bb9f2b06")
    }

    func testParametersSetOnInit() {
        output = AKFMOscillator(waveform: AKTable(.square),
                                baseFrequency: 1_234,
                                carrierMultiplier: 1.234,
                                modulatingMultiplier: 1.234,
                                modulationIndex: 1.234,
                                amplitude: 0.5)
        AKTestMD5("8387b7242dbb91c0a1f397a9bb9f2b06")
    }

    func testPresetBuzzer() {
        let preset = AKFMOscillator()
        preset.presetBuzzer()
        output = preset
        AKTestMD5("03e2f9736e2511fe99997c65df486bbc")
    }

    func testPresetFogHorn() {
        let preset = AKFMOscillator()
        preset.presetFogHorn()
        output = preset
        AKTestMD5("e4e9fad0f2fc0c91b886583ae1e0faf4")
    }

    func testPresetSpiral() {
        let preset = AKFMOscillator()
        preset.presetSpiral()
        output = preset
        AKTestMD5("4cbeac11faec88c9816be8d872028657")
    }

    func testPresetStunRay() {
        let preset = AKFMOscillator()
        preset.presetStunRay()
        output = preset
        AKTestMD5("3434fc08a63bc6b0a8e52fbcc41e3866")
    }

    func testPresetWobble() {
        let preset = AKFMOscillator()
        preset.presetWobble()
        output = preset
        AKTestMD5("4450350ff43f5f1b258158f1ec7dbccc")
    }

    func testSquareWave() {
        output = AKFMOscillator(waveform: AKTable(.square, count: 4_096))
        AKTestMD5("521697a9ca4ef19632576bbc4f57e51f")
    }

}
