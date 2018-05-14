//
//  AKFMOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFMOscillatorTests: AKTestCase {

    var preset = AKFMOscillator()

    override func setUp() {
        preset.rampDuration = 0.0
        super.setUp()
    }

    func testDefault() {
        output = AKFMOscillator()
        AKTestMD5("3fee66d7da663b3e68142de923962819")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKFMOscillator(waveform: AKTable(.square))
        oscillator.rampDuration = 0.0
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
        preset.presetBuzzer()
        output = preset
        AKTestMD5("03e2f9736e2511fe99997c65df486bbc")
    }

    func testPresetFogHorn() {
        preset.presetFogHorn()
        output = preset
        AKTestMD5("e4e9fad0f2fc0c91b886583ae1e0faf4")
    }

    func testPresetSpiral() {
        preset.presetSpiral()
        output = preset
        AKTestMD5("4cbeac11faec88c9816be8d872028657")
    }

    func testPresetStunRay() {
        preset.presetStunRay()
        output = preset
        AKTestMD5("3434fc08a63bc6b0a8e52fbcc41e3866")
    }

    func testPresetWobble() {
        preset.presetWobble()
        output = preset
        AKTestMD5("4450350ff43f5f1b258158f1ec7dbccc")
    }

    func testSquareWave() {
        output = AKFMOscillator(waveform: AKTable(.square, count: 4_096))
        AKTestMD5("521697a9ca4ef19632576bbc4f57e51f")
    }

}
