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
            return input.smoothDelay(time: 0.01 + ramp, samples: 512 + 512 * ramp, feedback: 0.99 - ramp)
        }
        AKTestMD5("5fad6c750dd3493bec59167606a51c59")
    }
    
//    func testDefault() {
//        output = AKOperationEffect(input) { input, _ in
//            return input.smoothDelay()
//        }
//        AKTestMD5("")
//    }
//
//    func testParameters() {
//        output = AKOperationEffect(input) { input, _ in
//            return input.smoothDelay(time: 0.1,
//                                     samples: 512,
//                                     feedback: 0.5,
//                                     maximumDelayTime: 1)
//        }
//        AKTestMD5("")
//    }
//
//    func testTime() {
//        output = AKOperationEffect(input) { input, _ in
//            return input.smoothDelay(time: 0.1)
//        }
//        AKTestMD5("")
//    }
//
//    func testSamples() {
//        output = AKOperationEffect(input) { input, _ in
//            return input.smoothDelay(samples: 512)
//        }
//        AKTestMD5("")
//    }
//
//    func testFeedback() {
//        output = AKOperationEffect(input) { input, _ in
//            return input.smoothDelay(feedback: 0.5)
//        }
//        AKTestMD5("")
//    }
}

