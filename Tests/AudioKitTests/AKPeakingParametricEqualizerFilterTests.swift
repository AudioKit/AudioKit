// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPeakingParametricEqualizerFilterTests: AKTestCase2 {

    func testCenterFrequency() {
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKPeakingParametricEqualizerFilter(input)
        AKTest()
    }

    func testGain() {
        output = AKPeakingParametricEqualizerFilter(input, gain: 2)
        AKTest()
    }

    func testParameters() {
        output = AKPeakingParametricEqualizerFilter(input, centerFrequency: 500, gain: 2, q: 1.414)
        AKTest()
    }

    func testQ() {
        output = AKPeakingParametricEqualizerFilter(input, q: 1.415)
        AKTest()
    }
}
