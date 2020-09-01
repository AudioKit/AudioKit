// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKKorgLowPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKKorgLowPassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKKorgLowPassFilter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKKorgLowPassFilter(input, cutoffFrequency: 500, resonance: 0.5, saturation: 1)
        AKTest()
    }

    func testResonance() {
        engine.output = AKKorgLowPassFilter(input, resonance: 0.5)
        AKTest()
    }

    func testSaturation() {
        engine.output = AKKorgLowPassFilter(input, saturation: 1)
        AKTest()
    }
}
