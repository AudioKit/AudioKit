// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighPassButterworthFilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKHighPassButterworthFilter(input, cutoffFrequency: 400)
        AKTest()
    }

    func testDefault() {
        output = AKHighPassButterworthFilter(input)
        AKTest()
    }

}
