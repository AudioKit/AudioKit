//
//  triangleWaveTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class triangleWaveTests: AKTestCase {

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
            return AKOperation.triangleWave(frequency: ramp * 2_000, amplitude: ramp)
        }
        AKTestMD5("4eddd8c721f3487810f91bff1be28cc3")
    }

}
