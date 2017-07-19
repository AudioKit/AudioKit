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

    // Not testing default because nearly every other test in AudioKit uses the oscillator default
    
    func testParametersSetOnInit() {
        let input = AKOscillator(waveform: AKTable(.square),
                              frequency: 400,
                              amplitude: 0.5)
        output = input
        input.start()
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }

    func testParametersSetAfterInit() {
        let input = AKOscillator(waveform: AKTable(.square))
        input.frequency = 400
        input.amplitude = 0.5
        output = input
        input.start()
        AKTestMD5("f6e65ca01b18cd5ee413d12a9287ca71")
    }
}
