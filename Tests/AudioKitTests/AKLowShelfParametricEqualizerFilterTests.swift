// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowShelfParametricEqualizerFilterTests: AKTestCase {

    func testCornerFrequency() {
        engine.output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKLowShelfParametricEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        engine.output = AKLowShelfParametricEqualizerFilter(input, gain: 2)
        AKTest()
    }

    func testParameters() {
        engine.output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500, gain: 2, q: 1.414)
        AKTest()
    }

    func testQ() {
        engine.output = AKLowShelfParametricEqualizerFilter(input, q: 1.415)
        AKTest()
    }
}
