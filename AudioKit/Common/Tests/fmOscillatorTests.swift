//
//  fmOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/5/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class FMOscillatorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.fmOscillator()
        }
        AKTestMD5("8d80fc784da9e2f0457870f9ebdfd17f")
    }

    func testFMOscillatorOperation() {
        output = AKOperationGenerator { _ in
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
        AKTestMD5("4a09613948839bbe5fe458524de8176a")
    }

}
