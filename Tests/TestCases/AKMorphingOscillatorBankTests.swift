//
//  AKMorphingOscillatorBankTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKMorphingOscillatorBankTests: AKTestCase {

    var inputBank: AKMorphingOscillatorBank!
    let waveforms = [AKTable(.sawtooth), AKTable(.sine), AKTable(.square), AKTable(.triangle)]

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0

        afterStart = {
            self.inputBank.play(noteNumber: 60, velocity: 120)
            self.inputBank.play(noteNumber: 64, velocity: 110)
            self.inputBank.play(noteNumber: 67, velocity: 100)
        }
    }

    func testAttackDuration() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, attackDuration: 0.123)
        output = inputBank
        AKTestMD5("a8eb74936c30722e24e1687f9398f1e4")
    }

    func testDecayDuration() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, decayDuration: 0.234)
        output = inputBank
        AKTestMD5("bfb5654f45aa822a3b37ade16d55f50b")
    }

    func testDefault() {
        inputBank = AKMorphingOscillatorBank()
        output = inputBank
        AKTestMD5("317b739a51d21c1b87dbebee209e2b0e")
    }

    func testIndex() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, index: 1.7)
        output = inputBank
        AKTestMD5("4cd9dfef4f3dc76944e9f9ce468b9c44")
    }

    // Known breakage on macOS
    #if os(iOS)
    func testParameters() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms,
                                             index: 1.7,
                                             attackDuration: 0.123,
                                             decayDuration: 0.234,
                                             sustainLevel: 0.345,
                                             pitchBend: 1,
                                             vibratoDepth: 1.1,
                                             vibratoRate: 1.2)
        output = inputBank
        AKTestMD5("bd119378ec447cf498bac22b98815883")
    }
    #endif

    func testPitchBend() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, pitchBend: 1.1)
        output = inputBank
        AKTestMD5("443dcfc1aa9c96f50b3f4ad5e7721882")
    }

    func testSustainLevel() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("8d23d71ec765ac2878ed986271149f34")
    }

    func testVibrato() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, vibratoDepth: 1, vibratoRate: 10)
        output = inputBank
        AKTestMD5("0db1ef4572600682a40b441fcf151d50")
    }

    func testWaveformArray() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms)
        output = inputBank
        AKTestMD5("4cd9dfef4f3dc76944e9f9ce468b9c44")
    }

}
