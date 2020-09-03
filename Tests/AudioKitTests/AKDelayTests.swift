// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDelayTests: AKTestCase {

    func testDryWetMix() {
        engine.output = AKDelay(input, time: 0.012_3, dryWetMix: 0.456)
        AKTest()
    }

    func testFeedback() {
        engine.output = AKDelay(input, time: 0.012_3, feedback: 0.345)
        AKTest()
    }

    func testLowpassCutoff() {
        engine.output = AKDelay(input, time: 0.012_3, lowPassCutoff: 1_234)
        AKTest()
    }

    func testParameters() {
        engine.output = AKDelay(input, time: 0.012_3, feedback: 0.345, lowPassCutoff: 1_234, dryWetMix: 0.456)
        AKTest()
    }

    func testTime() {
        engine.output = AKDelay(input, time: 0.012_3)
        AKTest()
    }

}
