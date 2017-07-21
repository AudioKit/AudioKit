//
//  AKMorphingOscillatorBankTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 7/21/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKMorphingOscillatorBankTests: AKTestCase {

    var input: AKMorphingOscillatorBank!
    let waveforms = [AKTable(.sawtooth), AKTable(.sine), AKTable(.square), AKTable(.triangle)]
    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0

        afterStart = {
            self.input.play(noteNumber: 60, velocity: 120)
            self.input.play(noteNumber: 64, velocity: 110)
            self.input.play(noteNumber: 67, velocity: 100)
        }
    }

    func testDefault() {
        input = AKMorphingOscillatorBank()
        output = input
        AKTestMD5("1f4e1e7d6257a538f631b9a093e95f8e")
    }

    func testParameters() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms,
                                         index: 1.7,
                                         attackDuration: 0.123,
                                         decayDuration: 0.234,
                                         sustainLevel: 0.345,
                                         detuningOffset: 1,
                                         detuningMultiplier: 1.1)
        output = input
        AKTestMD5("445f2962ea295e2ca26d72269e9e371e")
    }

    func testWaveformArray() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms)
        output = input
        AKTestMD5("03052ab575f7f163eb9614285cac2c03")
    }

    func testIndex() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms, index: 1.7)
        output = input
        AKTestMD5("03052ab575f7f163eb9614285cac2c03")
    }

    func testAttackDuration() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms, attackDuration: 0.123)
        output = input
        AKTestMD5("3b1d17d5324ec15d86a11da02bb3c949")
    }

    func testDecayDuration() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms, decayDuration: 0.234)
        output = input
        AKTestMD5("f7cc91e6d5667cbc362b00e1029aa1cd")
    }

    func testSustainLevel() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms, sustainLevel: 0.345)
        output = input
        AKTestMD5("88a25b6348559a5f5aa297b7c8c604e5")
    }

    func testDetuningOffset() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms, detuningOffset: 1)
        output = input
        AKTestMD5("58ce0608b69cb90ff1510c07ec6de0d5")
    }

    func testDetuningMultiplier() {
        input = AKMorphingOscillatorBank(waveformArray: waveforms, detuningMultiplier: 1.1)
        output = input
        AKTestMD5("8b79539a87192bb627f21857de7d9a77")
    }
}

