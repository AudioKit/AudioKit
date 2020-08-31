// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKLowShelfFilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKLowShelfFilter(input, cutoffFrequency: 100, gain: 1)
        AKTest()
    }

    func testDefault() {
        output = AKLowShelfFilter(input)
        AKTestNoEffect()
    }

    func testGain() {
        output = AKLowShelfFilter(input, gain: 1)
        AKTest()
    }
}
