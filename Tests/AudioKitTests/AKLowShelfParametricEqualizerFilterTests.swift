// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowShelfParametricEqualizerFilterTests: AKTestCase2 {

    func testCornerFrequency() {
        output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKLowShelfParametricEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        output = AKLowShelfParametricEqualizerFilter(input, gain: 2)
        AKTest()
    }

    func testParameters() {
        output = AKLowShelfParametricEqualizerFilter(input, cornerFrequency: 500, gain: 2, q: 1.414)
        AKTest()
    }

    func testQ() {
        output = AKLowShelfParametricEqualizerFilter(input, q: 1.415)
        AKTest()
    }
}
