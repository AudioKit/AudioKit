// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKLowPassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKLowPassFilter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKLowPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTest()
    }

    func testResonance() {
        engine.output = AKLowPassFilter(input, resonance: 1)
        AKTest()
    }
}
