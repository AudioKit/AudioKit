// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPeakLimiterTests: AKTestCase2 {

    func testAttackDuration() {
        output = AKPeakLimiter(input, attackDuration: 0.02)
        AKTest()
    }

    func testDecayDuration() {
        output = AKPeakLimiter(input, decayDuration: 0.03)
        AKTest()
    }

    func testDefault() {
        output = AKPeakLimiter(input)
        AKTest()
    }

    func testParameters() {
        output = AKPeakLimiter(input, attackDuration: 0.02, decayDuration: 0.03, preGain: 1)
        AKTest()
    }

    func testPreGain() {
        output = AKPeakLimiter(input, preGain: 1)
        AKTest()
    }
}
