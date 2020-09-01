// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBandRejectButterworthFilterTests: AKTestCase {

    func testBandwidth() {
        engine.output = AKBandRejectButterworthFilter(input, bandwidth: 200)
        AKTest()
    }

    func testCenterFrequency() {
        engine.output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKBandRejectButterworthFilter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTest()
    }

}
