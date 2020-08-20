// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFormantFilterTests: AKTestCase {

    func testAttack() {
        output = AKFormantFilter(input, attackDuration: 0.023_4)
        AKTest()
    }

    func testCenterFrequency() {
        output = AKFormantFilter(input, centerFrequency: 500)
        AKTest()
    }

    func testDecay() {
        output = AKFormantFilter(input, decayDuration: 0.023_4)
        AKTest()
    }

    func testDefault() {
        output = AKFormantFilter(input)
        AKTest()
    }
}
