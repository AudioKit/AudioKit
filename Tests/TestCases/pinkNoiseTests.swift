//
//  pinkNoiseTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class PinkNoiseTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationGenerator { _ in
            return AKOperation.pinkNoise()
        }
        AKTestMD5("ddf3ff7735d85181d93abd7655b9658b")
    }

    func testAmplitude() {
        output = AKOperationGenerator { _ in
            return AKOperation.pinkNoise(amplitude: 0.456)
        }
        AKTestMD5("225013a98880fabae9333b4b281dfbbe")
    }

    func testParameterSweep() {
        output = AKOperationGenerator { _ in
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: self.duration)
            return AKOperation.pinkNoise(amplitude: line)
        }
        AKTestMD5("a3ff6fe8636bee3dadad539a2448226f")
    }

}
