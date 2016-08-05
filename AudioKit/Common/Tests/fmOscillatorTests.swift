//
//  fmOscillatorTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/5/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class fmOscillatorTests: AKTestCase {
    
    var duration = 1.0

    func testFMOscillatorOperation() {
        let generator = AKOperationGenerator() { _ in
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
        AudioKit.testOutput(generator, duration: duration)
        let expectedMD5 = "c89e8a75eba1f867cd6e4fb7a3a267f2"
        let md5 = AudioKit.tester!.MD5
        XCTAssertEqual(expectedMD5, md5)
    }

}
