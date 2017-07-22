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

    func testDefault() {
        inputBank = AKOscillatorBank()
        output = inputBank
        AKTestMD5("0145ebc17e8d2c630c4e147dfc6fc91e")
    }

    func testParameters() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square),
                                     attackDuration: 0.123,
                                     decayDuration: 0.234,
                                     sustainLevel: 0.345,
                                     detuningOffset: 1,
                                     detuningMultiplier: 1.1)
        output = inputBank
        AKTestMD5("6444a94a67173f9dbc91a1ff9cfbee34")
    }

    func testWaveform() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square))
        output = inputBank
        AKTestMD5("9c29b663765865836602af149220f22c")
    }

    func testAttackDuration() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), attackDuration: 0.123)
        output = inputBank
        AKTestMD5("e364f86b7847ac402a64da3b323ac6ea")
    }

    func testDecayDuration() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), decayDuration: 0.234)
        output = inputBank
        AKTestMD5("4f288b9cd6cbfc85603166706e69baf2")
    }

    func testSustainLevel() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), sustainLevel: 0.345)
        output = inputBank
        AKTestMD5("fd9e77b16aa056686c8802ff84f63e58")
    }

    func testDetuningOffset() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), detuningOffset: 1)
        output = inputBank
        AKTestMD5("684403d76ed9051499e33a59509ac613")
    }

    func testDetuningMultiplier() {
        inputBank = AKOscillatorBank(waveform: AKTable(.square), detuningMultiplier: 1.1)
        output = inputBank
        AKTestMD5("a9336ad1b3f5ffba40b89e7e2a6237e6")
    }
}
