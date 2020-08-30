// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDecimatorTests: AKTestCase2 {

    func testDecimation() {
        output = AKDecimator(input, decimation: 0.75)
        AKTest()
    }

    func testDefault() {
        output = AKDecimator(input)
        AKTest()
    }

    func testMix() {
        output = AKDecimator(input, mix: 0.5)
        AKTest()
    }

    func testParameters() {
        output = AKDecimator(input, decimation: 0.75, rounding: 0.5, mix: 0.5)
        AKTest()
    }

    func testRounding() {
        output = AKDecimator(input, rounding: 0.5)
        AKTest()
    }

}
