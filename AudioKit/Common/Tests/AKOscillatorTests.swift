//
//  AKOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKOscillatorTests: AKTestCase {

    func testAmpitude() {
        input = AKOscillator(waveform: AKTable(.square), amplitude: 0.5)
        output = input
        AKTestMD5("24c58d48adb46e273d63088f6ca30208")
    }

    func testDefault() {
        output = input
        AKTestNoEffect()
    }

    func testFrequency() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400)
        output = input
        AKTestMD5("8827c22f2ccd32e59f14de86f1f00706")
    }

    func testParametersSetAfterInit() {
        input = AKOscillator(waveform: AKTable(.square))
        input.frequency = 400
        input.amplitude = 0.5
        output = input
        AKTestMD5("857cc2e5bd6ed2b8387966cadf44c9c1")
    }

    func testParameters() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input
        AKTestMD5("857cc2e5bd6ed2b8387966cadf44c9c1")
    }

}
