// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKThreePoleLowpassFilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKThreePoleLowpassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKThreePoleLowpassFilter(input)
        AKTest()
    }

    func testDistortion() {
        engine.output = AKThreePoleLowpassFilter(input, distortion: 1)
        AKTest()
    }

    func testParameters() {
        engine.output = AKThreePoleLowpassFilter(input, distortion: 1, cutoffFrequency: 500, resonance: 1)
        AKTest()
    }

    func testResonance() {
        engine.output = AKThreePoleLowpassFilter(input, resonance: 1)
        AKTest()
    }
}
