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
        AKTestMD5("33b78eb124aee08f135973c4e9d57f8c")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01, feedback: 0.99)
        }
        AKTestMD5("d02eb163c7d1cde255dabeddb810acc6")
    }

    func testParameterSweep() {
        output = AKOperationEffect(input) { input, _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(frequency: 1.0 / self.duration),
                start: 0,
                end: 0.99,
                duration: self.duration)
            return input.delay(time: 0.01, feedback: 0.99 - ramp)
        }
        AKTestMD5("a533a9264e5ed94a98524c1f57256f44")
    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01)
        }
        AKTestMD5("4293fae437009d21fe989288289e1918")
    }

    func testFeedback() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(feedback: 0.99)
        }
        AKTestMD5("cb55f9619ef98e69356a4f23cbe52d9a")
    }
}
