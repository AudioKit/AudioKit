//
//  AKOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2017 AudioKit. All rights reserved.
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
        AKTestMD5("d3998b51af7f54f1c9088973b931e9af")
    }

    func testParametersSetAfterInit() {
        input = AKOscillator(waveform: AKTable(.square))
        input.frequency = 400
        input.amplitude = 0.5
        output = input
        AKTestMD5("615e742bc1412c15237a453c5b49d5e0")
    }

    func testParameters() {
        input = AKOscillator(waveform: AKTable(.square), frequency: 400, amplitude: 0.5)
        output = input
        AKTestMD5("615e742bc1412c15237a453c5b49d5e0")
    }

}
