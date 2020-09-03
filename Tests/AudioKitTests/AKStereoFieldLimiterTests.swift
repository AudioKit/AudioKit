// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKStereoFieldLimiterTests: AKTestCase {

    func testDefault() {
        let pannedInput = AKPanner(input, pan: -1)
        engine.output = AKStereoFieldLimiter(pannedInput)
        AKTest()
    }

    func testHalf() {
        let pannedInput = AKPanner(input, pan: -1)
        engine.output = AKStereoFieldLimiter(pannedInput, amount: 0.5)
        AKTest()
    }

    func testNone() {
        let pannedInput = AKPanner(input, pan: -1)
        engine.output = AKStereoFieldLimiter(pannedInput, amount: 0)
        AKTest()
    }
}
