// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowPassButterworthFilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKLowPassButterworthFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKLowPassButterworthFilter(input)
        AKTest()
    }

}
