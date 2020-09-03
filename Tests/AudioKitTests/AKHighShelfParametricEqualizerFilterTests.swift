// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighShelfParametricEqualizerFilterTests: AKTestCase {

    func testCenterFrequency() {
        engine.output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKHighShelfParametricEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        engine.output = AKHighShelfParametricEqualizerFilter(input, gain: 2)
        AKTest()
    }

    func testParameters() {
        engine.output = AKHighShelfParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTest()
    }

    func testQ() {
        engine.output = AKHighShelfParametricEqualizerFilter(input, q: 1.415)
        AKTest()
    }
}
