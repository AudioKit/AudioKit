//
//  AKOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKOscillator()
        AKTestMD5("30e9a7639b3af4f8159e307bf48a2844")
    }

    func testParametersSetOnInit() {
        output = AKOscillator(waveform: AKTable(.square),
                              frequency: 400,
                              amplitude: 0.5)
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }

    func testParametersSetAfterInit() {
        let oscillator = AKOscillator(waveform: AKTable(.square))
        oscillator.frequency = 400
        oscillator.amplitude = 0.5
        output = oscillator
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }
}
