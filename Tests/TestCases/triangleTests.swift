//
//  triangleTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class TriangleTests: AKTestCase {

    var triangle = AKOperationGenerator { _ in return AKOperation.triangle() }

    override func setUp() {
        afterStart = { self.triangle.start() }
        duration = 1.0
    }

    func testParameterSweep() {
        triangle = AKOperationGenerator { _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: duration)
            return AKOperation.triangle(frequency: ramp * 2_000, amplitude: ramp, phase: ramp)
        }
        output = triangle
        AKTestMD5("33caf8c3dc1f5c474308e1ee788c0126")
    }

}
