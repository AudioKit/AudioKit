// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBandPassButterworthFilterTests: AKTestCase2 {

    func testBandwidth() {
        output = AKBandPassButterworthFilter(input, bandwidth: 200)
        AKTest()
    }

    func testCenterFrequency() {
        output = AKBandPassButterworthFilter(input, centerFrequency: 1_500)
        AKTest()
    }

    func testDefault() {
        output = AKBandPassButterworthFilter(input)
        AKTest()
    }

    func testParameters() {
        output = AKBandPassButterworthFilter(input, centerFrequency: 1_500, bandwidth: 200)
        AKTest()
    }

}
