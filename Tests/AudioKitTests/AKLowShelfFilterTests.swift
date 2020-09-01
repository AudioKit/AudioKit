// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowShelfFilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKLowShelfFilter(input, cutoffFrequency: 100, gain: 1)
        AKTest()
    }

    func testDefault() {
        engine.output = AKLowShelfFilter(input)
        AKTestNoEffect()
    }

    func testGain() {
        engine.output = AKLowShelfFilter(input, gain: 1)
        AKTest()
    }
}
