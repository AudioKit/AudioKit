// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighPassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKHighPassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKHighPassFilter(input)
        AKTest()
    }

    func testParameters() {
        output = AKHighPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTest()
    }

    func testResonance() {
        output = AKHighPassFilter(input, resonance: 1)
        AKTest()
    }
}
