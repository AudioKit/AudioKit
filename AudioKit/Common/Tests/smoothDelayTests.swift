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

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay()
        }
        AKTestMD5("7e376e052ae31ea9f1e4648e88899dc5")
    }

    func testFeedback() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(feedback: 0.66)
        }
        AKTestMD5("7e376e052ae31ea9f1e4648e88899dc5")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.05, feedback: 0.66, samples: 256)
        }
        AKTestMD5("b02fdc5cc0707ffd25a5233a1426ba1f")
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
        AKTestMD5("4005d6952ee19edf5c9786d622ab9dc8")
    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.05)
        }
        AKTestMD5("deb547191eb922406984bcc5cff3fa87")
    }

}
