// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBandRejectButterworthFilterTests: AKTestCase {

    func testBandwidth() {
        output = AKBandRejectButterworthFilter(input, bandwidth: 200)
        AKTest()
    }

    func testCenterFrequency() {
        output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500)
        AKTest()
    }

    func testDefault() {
        output = AKBandRejectButterworthFilter(input)
        AKTest()
    }

    func testParameters() {
        output = AKBandRejectButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTest()
    }

}
