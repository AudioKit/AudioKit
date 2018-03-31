//
//  AKPhaseDistortionOscillatorBankTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPhaseDistortionOscillatorBankTests: AKTestCase {

    var inputBank: AKPhaseDistortionOscillatorBank!

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
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), attackDuration: 0.123)
        output = inputBank
        AKTestMD5("112fb874aff5f0677cf5f950ef62159f")
    }

    func testDecayDuration() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = inputBank
        AKTestMD5("7b7a097bf819f4dce3cbc816735cc87b")
    }

    func testDefault() {
        inputBank = AKPhaseDistortionOscillatorBank()
        output = inputBank
        AKTestMD5("83c94d8814893465c4ebdd6093223e50")
    }

    // Known breakage on macOS
    #if os(iOS)
    func testParameters() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square),
                                                    phaseDistortion: 0.5,
                                                    attackDuration: 0.123,
                                                    decayDuration: 0.234,
                                                    sustainLevel: 0.345,
                                                    pitchBend: 1,
                                                    vibratoDepth: 1.1,
                                                    vibratoRate: 1.2)
        output = inputBank
        AKTestMD5("d1417d0a8790bd44b578144656abd689")
    }
    #endif

    func testPhaseDistortion() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), phaseDistortion: 0.5)
        output = inputBank
        AKTestMD5("27c8b60b25d8dd4146c4c90d45ff632f")
    }

    func testPitchBend() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), pitchBend: 1)
        output = inputBank
        AKTestMD5("acca174c1da73cce418582cc9628e75c")
    }

    // Known breakage on macOS
    #if os(iOS)
    func testSustainLevel() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("555e3b76a46be2c1dd619cfaec306a92")
    }
    #endif

    // Known breakage on macOS
    #if os(iOS)
    func testVibrato() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), vibratoDepth: 1.1, vibratoRate: 10)
        output = inputBank
        AKTestMD5("662fbe529db0ecbf3b4b689609ada91c")
    }
    #endif

    func testWaveform() {
        inputBank = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square))
        output = inputBank
        AKTestMD5("0bb6f474701b0fc62ac64160819fc4ce")
    }

}
