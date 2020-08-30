// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKEqualizerFilterTests: AKTestCase2 {

    func testBandwidth() {
        output = AKEqualizerFilter(input, bandwidth: 50)
        AKTest()
    }

    func testCenterFrequency() {
        output = AKEqualizerFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        output = AKEqualizerFilter(input, gain: 5)
        AKTest()
    }

    func testParameters() {
        output = AKEqualizerFilter(input, centerFrequency: 500, bandwidth: 50, gain: 5)
        AKTest()
    }

}
