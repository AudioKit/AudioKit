//
//  delayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class DelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 5.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay()
        }
        AKTestMD5("e1f204032e3e37c75551f9bd6bc53e89")
    }

    func testFeedback() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(feedback: 0.99)
        }
        AKTestMD5("5422eea539cebf3530b7b4f665214cce")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01, feedback: 0.99)
        }
        AKTestMD5("34c508d5ce57651024935660f7e3c877")
    }

//    func testParameterSweep() {
//        output = AKOperationEffect(input) { input, _ in
//            let ramp = AKOperation.lineSegment(
//                trigger: AKOperation.metronome(frequency: 1.0 / self.duration),
//                start: 0,
//                end: 0.99,
//                duration: self.duration)
//            return input.delay(time: 0.01, feedback: 0.99 - ramp)
//        }
//        AKTestMD5("")
//    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01)
        }
        AKTestMD5("102a6ed78dc39aec1a209302008800ef")
    }

}
