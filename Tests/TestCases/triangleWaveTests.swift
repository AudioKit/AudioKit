//
//  triangleWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class TriangleWaveTests: AKTestCase {


    var triangle = AKOperationGenerator { _ in return AKOperation.triangleWave() }

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
                duration: self.duration)
            return AKOperation.triangleWave(frequency: ramp * 2_000, amplitude: ramp)
        }
        output = triangle
        AKTestMD5("4eddd8c721f3487810f91bff1be28cc3")
    }

}
