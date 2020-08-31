// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowPassFilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKLowPassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKLowPassFilter(input)
        AKTest()
    }

    func testParameters() {
        output = AKLowPassFilter(input, cutoffFrequency: 500, resonance: 1)
        AKTest()
    }

    func testResonance() {
        output = AKLowPassFilter(input, resonance: 1)
        AKTest()
    }
}
