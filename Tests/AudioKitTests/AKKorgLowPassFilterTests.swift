// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKKorgLowPassFilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKKorgLowPassFilter(input)
        AKTest()
    }

    func testParameters() {
        output = AKKorgLowPassFilter(input, cutoffFrequency: 500, resonance: 0.5, saturation: 1)
        AKTest()
    }

    func testResonance() {
        output = AKKorgLowPassFilter(input, resonance: 0.5)
        AKTest()
    }

    func testSaturation() {
        output = AKKorgLowPassFilter(input, saturation: 1)
        AKTest()
    }
}
