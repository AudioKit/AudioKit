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

    var oscillator = AKFMOscillator()

    override func setUp() {
        oscillator.rampDuration = 0.0
        afterStart = { self.oscillator.start() }
    }

    func testDefault() {
        output = oscillator
        AKTestMD5("3fee66d7da663b3e68142de923962819")
    }

    func testParametersSetAfterInit() {
        oscillator = AKFMOscillator(waveform: AKTable(.square))
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
        oscillator = AKFMOscillator(waveform: AKTable(.square),
                                    baseFrequency: 1_234,
                                    carrierMultiplier: 1.234,
                                    modulatingMultiplier: 1.234,
                                    modulationIndex: 1.234,
                                    amplitude: 0.5)
        output = oscillator
        AKTestMD5("8387b7242dbb91c0a1f397a9bb9f2b06")
    }

    func testPresetBuzzer() {
        oscillator.presetBuzzer()
        output = oscillator
        AKTestMD5("03e2f9736e2511fe99997c65df486bbc")
    }

    func testPresetFogHorn() {
        oscillator.presetFogHorn()
        output = oscillator
        AKTestMD5("e4e9fad0f2fc0c91b886583ae1e0faf4")
    }

    func testPresetSpiral() {
        oscillator.presetSpiral()
        output = oscillator
        AKTestMD5("4cbeac11faec88c9816be8d872028657")
    }

    func testPresetStunRay() {
        oscillator.presetStunRay()
        output = oscillator
        AKTestMD5("3434fc08a63bc6b0a8e52fbcc41e3866")
    }

    func testPresetWobble() {
        oscillator.presetWobble()
        output = oscillator
        AKTestMD5("4450350ff43f5f1b258158f1ec7dbccc")
    }

    func testSquareWave() {
        oscillator = AKFMOscillator(waveform: AKTable(.square, count: 4_096))
        output = oscillator
        AKTestMD5("521697a9ca4ef19632576bbc4f57e51f")
    }

}
