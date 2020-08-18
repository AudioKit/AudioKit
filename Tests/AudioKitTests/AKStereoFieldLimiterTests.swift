// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKStereoFieldLimiterTests: AKTestCase {

    func testDefault() {
        let pannedInput = AKPanner(input, pan: -1)
        output = AKStereoFieldLimiter(pannedInput)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }

    func testHalf() {
        let pannedInput = AKPanner(input, pan: -1)
        output = AKStereoFieldLimiter(pannedInput, amount: 0.5)
        AKTestMD5("3cb8df3c2ff7f79a0532029bfb6afb9a")
    }

    func testNone() {
        let pannedInput = AKPanner(input, pan: -1)
        output = AKStereoFieldLimiter(pannedInput, amount: 0)
        AKTestMD5("f1a562907d9bcc8af6463d75633a14c2")
    }
}
