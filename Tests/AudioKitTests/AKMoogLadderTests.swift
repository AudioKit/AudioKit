// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKMoogLadderTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKMoogLadder(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        output = AKMoogLadder(input)
        AKTest()
    }

    func testParameters() {
        output = AKMoogLadder(input, cutoffFrequency: 500, resonance: 0.9)
        AKTest()
    }

    func testResonance() {
        output = AKMoogLadder(input, resonance: 0.9)
        AKTest()
    }

}
