// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class SmoothDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 4.0
    }

    func testDefault() {
        engine.output = AKOperationEffect(input) { $0.smoothDelay() }
        AKTest()
    }

    func testFeedback() {
        engine.output = AKOperationEffect(input) { $0.smoothDelay(feedback: 0.66) }
        AKTest()
    }

    func testParameters() {
        engine.output = AKOperationEffect(input) { $0.smoothDelay(time: 0.05, feedback: 0.66, samples: 256) }
        AKTest()
    }

    func testParameterSweep() {
        engine.output = AKOperationEffect(input) { input in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(frequency: 1.0 / duration),
                start: 0.0,
                end: 0.1,
                duration: duration)
            return input.smoothDelay(time: 0.01 + ramp, feedback: 0.99 - ramp, samples: 512)
        }
        AKTest()
    }

    func testTime() {
        engine.output = AKOperationEffect(input) { $0.smoothDelay(time: 0.05) }
        AKTest()
    }

}
