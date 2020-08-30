// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDelayTests: AKTestCase2 {

    func testDryWetMix() {
        output = AKDelay(input, time: 0.012_3, dryWetMix: 0.456)
        AKTest()
    }

    func testFeedback() {
        output = AKDelay(input, time: 0.012_3, feedback: 0.345)
        AKTest()
    }

    func testLowpassCutoff() {
        output = AKDelay(input, time: 0.012_3, lowPassCutoff: 1_234)
        AKTest()
    }

    func testParameters() {
        output = AKDelay(input, time: 0.012_3, feedback: 0.345, lowPassCutoff: 1_234, dryWetMix: 0.456)
        AKTest()
    }

    func testTime() {
        output = AKDelay(input, time: 0.012_3)
        AKTest()
    }

}
