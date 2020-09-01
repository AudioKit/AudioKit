// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKEqualizerFilterTests: AKTestCase {

    func testBandwidth() {
        engine.output = AKEqualizerFilter(input, bandwidth: 50)
        AKTest()
    }

    func testCenterFrequency() {
        engine.output = AKEqualizerFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        engine.output = AKEqualizerFilter(input, gain: 5)
        AKTest()
    }

    func testParameters() {
        engine.output = AKEqualizerFilter(input, centerFrequency: 500, bandwidth: 50, gain: 5)
        AKTest()
    }

}
