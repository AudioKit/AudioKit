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
        AKTestMD5("f5032eb3fc926f68a73fec67e29c6ac7")
    }

    func testAmplitude() {
        output = AKOperationGenerator { _ in
            return AKOperation.pinkNoise(amplitude: 0.456)
        }
        AKTestMD5("fe160cb0de91109574515f9bef8e3286")
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
        AKTestMD5("db9904288c8872a06a87a6d4913eb942")
    }

}
