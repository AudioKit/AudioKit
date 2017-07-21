//
//  AKPhaseDistortionOscillatorBankTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 7/21/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPhaseDistortionOscillatorBankTests: AKTestCase {

    var input: AKPhaseDistortionOscillatorBank!

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
        input = AKPhaseDistortionOscillatorBank()
        output = input
        AKTestMD5("83c94d8814893465c4ebdd6093223e50")
    }

    func testParameters() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square),
                                                phaseDistortion: 0.5,
                                                attackDuration: 0.123,
                                                decayDuration: 0.234,
                                                sustainLevel: 0.345,
                                                detuningOffset: 1,
                                                detuningMultiplier: 1.1)
        output = input
        AKTestMD5("7fff8695bccf0cda763f090cda22f6bc")
    }

    func testWaveform() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square))
        output = input
        AKTestMD5("0bb6f474701b0fc62ac64160819fc4ce")
    }

    func testPhaseDistortion() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), phaseDistortion: 0.5)
        output = input
        AKTestMD5("27c8b60b25d8dd4146c4c90d45ff632f")
    }

    func testAttackDuration() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), attackDuration: 0.123)
        output = input
        AKTestMD5("112fb874aff5f0677cf5f950ef62159f")
    }

    func testDecayDuration() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = input
        AKTestMD5("7b7a097bf819f4dce3cbc816735cc87b")
    }

    func testSustainLevel() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = input
        AKTestMD5("555e3b76a46be2c1dd619cfaec306a92")
    }

    func testDetuningOffset() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), detuningOffset: 1)
        output = input
        AKTestMD5("5d2250ac42904e9a4739b04dded59bf1")
    }

    func testDetuningMultiplier() {
        input = AKPhaseDistortionOscillatorBank(waveform: AKTable(.square), detuningMultiplier: 1.1)
        output = input
        AKTestMD5("d251fd32a650e87f6cd27f4f3804051c")
    }
}

