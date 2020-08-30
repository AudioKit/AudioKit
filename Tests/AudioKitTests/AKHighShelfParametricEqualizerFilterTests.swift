// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighShelfParametricEqualizerFilterTests: AKTestCase2 {

    func testCenterFrequency() {
        output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKHighShelfParametricEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        output = AKHighShelfParametricEqualizerFilter(input, gain: 2)
        AKTest()
    }

    func testParameters() {
        output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTest()
    }

    func testQ() {
        output = AKHighShelfParametricEqualizerFilter(input, q: 1.415)
        AKTest()
    }
}
