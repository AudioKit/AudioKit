// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBandPassButterworthFilterTests: AKTestCase {

    func testBandwidth() {
        engine.output = AKBandPassButterworthFilter(input, bandwidth: 200)
        AKTest()
    }

    func testCenterFrequency() {
        engine.output = AKBandPassButterworthFilter(input, centerFrequency: 1_500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKBandPassButterworthFilter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKBandPassButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTest()
    }

}
