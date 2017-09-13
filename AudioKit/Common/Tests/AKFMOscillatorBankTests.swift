//
//  AKFMOscillatorBankTests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 7/21/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKFMOscillatorBankTests: AKTestCase {

    var inputBank: AKFMOscillatorBank!

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
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), attackDuration: 0.123)
        output = inputBank
        AKTestMD5("27d7352154c2abbe3f00a7f66aa1a2ae")
    }

    func testCarrierMultiplier() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), carrierMultiplier: 1.1)
        output = inputBank
        AKTestMD5("04f54473a8adb63d75bd6f7e7f670736")
    }

    func testDecayDuration() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = inputBank
        AKTestMD5("221a728592f2aab5f0b174eb6ce4fcae")
    }

    func testDefault() {
        inputBank = AKFMOscillatorBank()
        output = inputBank
        AKTestMD5("b06c09a1f2da0383337362b724a73d8e")
    }

    func testModulatingMultiplier() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), modulatingMultiplier: 1.2)
        output = inputBank
        AKTestMD5("07831f95ab5e7cab6db3cdfe4c01bfa6")
    }

    func testModulationIndex() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), modulationIndex:  1.3)
        output = inputBank
        AKTestMD5("0cdbe4e0546a81e0ac1ab929c71cf864")
    }

    func testParameters() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square),
                                       carrierMultiplier: 1.1,
                                       modulatingMultiplier: 1.2,
                                       modulationIndex:  1.3,
                                       attackDuration: 0.123,
                                       decayDuration: 0.234,
                                       sustainLevel: 0.345,
                                       pitchBend: 1,
                                       vibratoDepth: 1.1,
                                       vibratoRate: 1.2)
        output = inputBank
        AKTestMD5("d50766edb7fb287cf4a861420e868067")
    }

    func testPitchBend() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), pitchBend: 1.1)
        output = inputBank
        AKTestMD5("16bc452b712520b74c79c9778593515e")
    }

    func testSustainLevel() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("af8765a1937447caed4461e30fdea889")
    }

    func testVibrato() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square), vibratoDepth: 1, vibratoRate: 10)
        output = inputBank
        AKTestMD5("909b0fe4dc480e9c768322b73564a5fe")
    }

    func testWaveform() {
        inputBank = AKFMOscillatorBank(waveform: AKTable(.square))
        output = inputBank
        AKTestMD5("0c0d418d740c1cc53a9afd232122bb44")
    }
}
