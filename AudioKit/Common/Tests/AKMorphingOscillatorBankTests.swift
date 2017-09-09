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
        AKTestMD5("c3dda6103bb693aef41ec27806e3d4c3")
    }

    func testDecayDuration() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, decayDuration: 0.234)
        output = inputBank
        AKTestMD5("05af83eb0e1204a9778bdb77d90dc537")
    }

    func testDefault() {
        inputBank = AKMorphingOscillatorBank()
        output = inputBank
        AKTestMD5("17345f26560ce643990c5a269ab74a43")
    }

    func testIndex() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, index: 1.7)
        output = inputBank
        AKTestMD5("460123ae0622996dd8f04441dff25e8b")
    }

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
        AKTestMD5("cf78944a8431b5ee0440fa7b1b124493")
    }

    func testPitchBend() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, pitchBend: 1.1)
        output = inputBank
        AKTestMD5("effb427b8635ec021ca792d7ff2a0832")
    }

    func testSustainLevel() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("37a2084b030c5b29a3553a00c30aa61a")
    }

    func testVibrato() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms, vibratoDepth: 1, vibratoRate: 10)
        output = inputBank
        AKTestMD5("4be5ef808007fcdcc73f74dfb7603216")
    }

    func testWaveformArray() {
        inputBank = AKMorphingOscillatorBank(waveformArray: waveforms)
        output = inputBank
        AKTestMD5("460123ae0622996dd8f04441dff25e8b")
    }

}
