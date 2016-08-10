//
//  threePoleLowPassFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

@testable import AudioKit

class threePoleLowPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testParameterSweep() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: self.duration)
            return input.threePoleLowPassFilter(distortion: ramp, cutoffFrequency: ramp * 8000, resonance: ramp * 0.9)
        }
        AKTestMD5("ed404fb1aad4a455acef28ff339d6819")
    }

}
