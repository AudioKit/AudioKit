// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class SmoothDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 4.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay()
        }
        AKTest()
    }

    func testFeedback() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(feedback: 0.66)
        }
        AKTest()
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.05, feedback: 0.66, samples: 256)
        }
        AKTest()
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
        AKTest()
    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.05)
        }
        AKTest()
    }

}
