// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPeakingParametricEqualizerFilterTests: AKTestCase {

    func testCenterFrequency() {
        engine.output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKPeakingParametricEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        engine.output = AKPeakingParametricEqualizerFilter(input, gain: 2)
        AKTest()
    }

    func testParameters() {
        engine.output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTest()
    }

    func testQ() {
        engine.output = AKPeakingParametricEqualizerFilter(input, q: 1.415)
        AKTest()
    }
}
