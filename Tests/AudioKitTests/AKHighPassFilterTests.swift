// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKHighPassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKHighPassFilter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKHighPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTest()
    }

    func testResonance() {
        engine.output = AKHighPassFilter(input, resonance: 1)
        AKTest()
    }
}
