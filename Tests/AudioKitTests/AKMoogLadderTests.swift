// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKMoogLadderTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKMoogLadder(input, cutoffFrequency: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKMoogLadder(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKMoogLadder(input, cutoffFrequency: 500, resonance: 0.9)
        AKTest()
    }

    func testResonance() {
        engine.output = AKMoogLadder(input, resonance: 0.9)
        AKTest()
    }

}
