//
//  triangleTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class TriangleTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testParameterSweep() {
        output = AKOperationGenerator { _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: self.duration)
            return AKOperation.triangle(frequency: ramp * 2_000, amplitude: ramp, phase: ramp)
        }
        AKTestMD5("2f01ae01dcb43f267d0854ddea5db002")
    }

}
