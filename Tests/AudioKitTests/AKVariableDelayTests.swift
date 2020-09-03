// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKVariableDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 5.0 // needs to be this long since the default time is one second
    }

    func testDefault() {
        engine.output = AKVariableDelay(input)
        AKTest()
    }

    func testFeedback() {
        engine.output = AKVariableDelay(input, feedback: 0.95)
        AKTest()
    }

    func testMaximum() {
        engine.output = AKVariableDelay(input, time: 0.02, feedback: 0.8, maximumTime: 0.02)
        AKTest()
    }

    func testMaximumSurpassed() {
        engine.output = AKVariableDelay(input, time: 0.03, feedback: 0.8, maximumTime: 0.02)
        AKTest()
    }

    func testParametersSetAfterInit() {
        let effect = AKVariableDelay(input)
        effect.rampDuration = 0.0
        effect.time = 0.123_4
        effect.feedback = 0.95
        engine.output = effect
        AKTest()
    }

    func testParametersSetOnInit() {
        engine.output = AKVariableDelay(input, time: 0.123_4, feedback: 0.95)
        AKTest()
    }

    func testTime() {
        engine.output = AKVariableDelay(input, time: 0.123_4)
        AKTest()
    }

}
