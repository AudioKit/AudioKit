//
//  AKOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKOscillatorTests: AKTestCase {

    func testDefault() {
        output = AKOscillator()
        AKTestMD5("221e422c2ced547a391a18900ef08516")
    }
    
    func testParametersSetOnInit() {
        output = AKOscillator(waveform: AKTable(.Square),
                              frequency: 400,
                              amplitude: 0.5)
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }
    
    func testParametersSetAfterInit() {
        let oscillator = AKOscillator(waveform: AKTable(.Square))
        oscillator.frequency = 400
        oscillator.amplitude = 0.5
        output = oscillator
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }
}
