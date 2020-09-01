// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class DelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 5.0
    }

    func testDefault() {
        engine.output = AKOperationEffect(input) { $0.delay() }
        AKTest()
    }

    func testFeedback() {
        engine.output = AKOperationEffect(input) { $0.delay(feedback: 0.99) }
        AKTest()
    }

    func testParameters() {
        engine.output = AKOperationEffect(input) { $0.delay(time: 0.01, feedback: 0.99) }
        AKTest()
    }

    func testTime() {
        engine.output = AKOperationEffect(input) { $0.delay(time: 0.01) }
        AKTest()
    }

}
