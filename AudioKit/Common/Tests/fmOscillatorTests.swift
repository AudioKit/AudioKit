//
//  fmOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/5/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class fmOscillatorTests: AKTestCase {
    
    override func setUp() {
        super.setUp()
        duration = 1.0
    }
    
    func testDefault() {
        output = AKOperationGenerator() { _ in
            return AKOperation.fmOscillator()
        }
        AKTestMD5("7b67fe4fc2ac128d6010cc93e47250ed")
    }
    
    func testFMOscillatorOperation() {
        output = AKOperationGenerator() { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(frequency: 0.1),
                start: 0.001, end: 5, duration: self.duration)
            return AKOperation.fmOscillator(
                baseFrequency: line * 1000,
                carrierMultiplier: line,
                modulatingMultiplier: 5.1 - line,
                modulationIndex: line * 6,
                amplitude: line / 5)
        }
        AKTestMD5("c89e8a75eba1f867cd6e4fb7a3a267f2")
    }

}
