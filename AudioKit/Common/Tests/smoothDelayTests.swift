//
//  smoothDelayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class SmoothDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 4.0
    }

    func testParameterSweep() {
        output = AKOperationEffect(input) { input, _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(frequency: 1.0 / self.duration),
                start: 0,
                end: 0.1,
                duration: self.duration)
            return input.smoothDelay(time: 0.01 + ramp, feedback: 0.99 - ramp, samples: 512)
        }
        AKTestMD5("27ada204f2cda9e35b0d8146d9023bef")
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay()
        }
        AKTestMD5("7d4cc8cdd65fdf1faa7dc9891a7c6a16")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.05, feedback: 0.66, samples: 256)
        }
        AKTestMD5("906e6762253b38a8044ffe1e3bc7e932")
    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.05)
        }
        AKTestMD5("b56006b891059151be4e34848c3f196f")
    }

    func testFeedback() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(feedback: 0.66)
        }
        AKTestMD5("7d4cc8cdd65fdf1faa7dc9891a7c6a16")
    }
}
