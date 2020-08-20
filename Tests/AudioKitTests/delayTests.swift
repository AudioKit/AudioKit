// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class DelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 5.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay()
        }
        AKTest()
    }

    func testFeedback() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(feedback: 0.99)
        }
        AKTest()
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01, feedback: 0.99)
        }
        AKTest()
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
//        AKTest("")
//    }

    func testTime() {
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.01)
        }
        AKTest()
    }

}
