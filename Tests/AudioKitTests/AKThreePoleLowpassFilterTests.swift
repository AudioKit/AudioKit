// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKThreePoleLowpassFilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKThreePoleLowpassFilter(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKThreePoleLowpassFilter(input)
        AKTest()
    }

    func testDistortion() {
        output = AKThreePoleLowpassFilter(input, distortion: 1)
        AKTest()
    }

    func testParameters() {
        output = AKThreePoleLowpassFilter(input, distortion: 1, cutoffFrequency: 500, resonance: 1)
        AKTest()
    }

    func testResonance() {
        output = AKThreePoleLowpassFilter(input, resonance: 1)
        AKTest()
    }
}
