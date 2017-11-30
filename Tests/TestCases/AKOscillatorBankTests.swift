//
//  AKOscillatorBankTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 7/21/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKOscillatorBankTests: AKTestCase {

    var inputBank: AKOscillatorBank!

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
        inputBank = AKOscillatorBank(waveform: AKTable(.square), attackDuration: 0.123)
        output = inputBank
        AKTestMD5("dbe8924aa51c874c8785e4e2b43cad32")
    }

    func testDecayDuration() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = inputBank
        AKTestMD5("9b1d91ec29a4042c7ad050e9b574802e")
    }

    func testDefault() {
        inputBank = AKOscillatorBank()
        output = inputBank
        AKTestMD5("3bbacd39af8272266b2e4a5a05257800")
    }

// Known Failing Test (inconsistencies in iOS/macOS)
//    func testParameters() {
//        inputBank = AKOscillatorBank(waveform: AKTable(.square),
//                                     attackDuration: 0.123,
//                                     decayDuration: 0.234,
//                                     sustainLevel: 0.345,
//                                     pitchBend: 1,
//                                     vibratoDepth: 1.1,
//                                     vibratoRate: 1.2)
//        output = inputBank
//        AKTestMD5("93a8e6f26e3f3326202348855caa0051")
//    }

    func testPitchBend() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), pitchBend: 1.1)
        output = inputBank
        AKTestMD5("db148878395ded60b26772e8f410fc6b")
    }

    func testSustainLevel() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("f60e7eb749054f53d93f9dd0969a4f56")
    }

    func testVibrato() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), vibratoDepth: 1, vibratoRate: 10)
        output = inputBank
        AKTestMD5("ca6b355d0116190474476a66d9ddb31c")
    }

    func testWaveform() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square))
        output = inputBank
        AKTestMD5("bf088a9d8142cb119b05cdd31254b86e")
    }

}
