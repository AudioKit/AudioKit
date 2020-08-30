// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKStereoFieldLimiterTests: AKTestCase2 {

    func testDefault() {
        let pannedInput = AKPanner(input, pan: -1)
        output = AKStereoFieldLimiter(pannedInput)
        AKTest()
    }

    func testHalf() {
        let pannedInput = AKPanner(input, pan: -1)
        output = AKStereoFieldLimiter(pannedInput, amount: 0.5)
        AKTest()
    }

    func testNone() {
        let pannedInput = AKPanner(input, pan: -1)
        output = AKStereoFieldLimiter(pannedInput, amount: 0)
        AKTest()
    }
}
