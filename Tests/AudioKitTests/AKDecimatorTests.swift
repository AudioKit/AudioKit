// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDecimatorTests: AKTestCase {

    func testDecimation() {
        engine.output = AKDecimator(input, decimation: 0.75)
        AKTest()
    }

    func testDefault() {
        engine.output = AKDecimator(input)
        AKTest()
    }

    func testMix() {
        engine.output = AKDecimator(input, mix: 0.5)
        AKTest()
    }

    func testParameters() {
        engine.output = AKDecimator(input, decimation: 0.75, rounding: 0.5, mix: 0.5)
        AKTest()
    }

    func testRounding() {
        engine.output = AKDecimator(input, rounding: 0.5)
        AKTest()
    }

}
