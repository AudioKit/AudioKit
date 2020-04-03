//
//  fmOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class FMOscillatorTests: AKTestCase {

    var oscillator = AKOperationGenerator { _ in return AKOperation.fmOscillator() }

    override func setUp() {
        afterStart = { self.oscillator.start() }
        duration = 1.0
    }

    func testDefault() {
        output = oscillator
        AKTestMD5("8d80fc784da9e2f0457870f9ebdfd17f")
    }

    func testFMOscillatorOperation() {
        oscillator = AKOperationGenerator { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(frequency: 0.1),
                start: 0.001, end: 5, duration: self.duration)
            return AKOperation.fmOscillator(
                baseFrequency: line * 1_000,
                carrierMultiplier: line,
                modulatingMultiplier: 5.1 - line,
                modulationIndex: line * 6,
                amplitude: line / 5)
        }
        output = oscillator
        AKTestMD5("4a09613948839bbe5fe458524de8176a")
    }

}
