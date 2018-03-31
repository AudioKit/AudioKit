//
//  AKOscillatorBankTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
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
        AKTestMD5("b25c325f1d2091d33f2f0f036c5ded24")
    }

    func testDecayDuration() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = inputBank
        AKTestMD5("419117345037b29da119b030a77a952a")
    }

    func testDefault() {
        inputBank = AKOscillatorBank()
        output = inputBank
        AKTestMD5("3bbacd39af8272266b2e4a5a05257800")
    }

    // Known breakage on macOS
    #if os(iOS)
    func testParameters() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square),
                                     attackDuration: 0.123,
                                     decayDuration: 0.234,
                                     sustainLevel: 0.345,
                                     pitchBend: 1,
                                     vibratoDepth: 1.1,
                                     vibratoRate: 1.2)
        output = inputBank
        AKTestMD5("a5c13b5223afae0fd5d83ef0ea55c5b9")
    }
    #endif

    func testPitchBend() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), pitchBend: 1.1)
        output = inputBank
        AKTestMD5("922610b5edc76f0e5a624a5afe8a325b")
    }

    func testSustainLevel() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("c6cb18ff48d3e24111b552a997213e54")
    }

    func testVibrato() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), vibratoDepth: 1, vibratoRate: 10)
        output = inputBank
        AKTestMD5("ba258bbdcdc045967e8a3ade47b0ccbb")
    }

    func testWaveform() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square))
        output = inputBank
        AKTestMD5("b9aad8bba7b07c628f89356ef9ba47ee")
    }

}
