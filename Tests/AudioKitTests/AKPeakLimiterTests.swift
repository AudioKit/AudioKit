// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPeakLimiterTests: AKTestCase {

    func testAttackDuration() {
        engine.output = AKPeakLimiter(input, attackDuration: 0.02)
        AKTest()
    }

    func testDecayDuration() {
        engine.output = AKPeakLimiter(input, decayDuration: 0.03)
        AKTest()
    }

    func testDefault() {
        engine.output = AKPeakLimiter(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKPeakLimiter(input, attackDuration: 0.02, decayDuration: 0.03, preGain: 1)
        AKTest()
    }

    func testPreGain() {
        engine.output = AKPeakLimiter(input, preGain: 1)
        AKTest()
    }
}
