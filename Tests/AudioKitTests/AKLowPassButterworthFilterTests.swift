// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowPassButterworthFilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKLowPassButterworthFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKLowPassButterworthFilter(input)
        AKTest()
    }

}
