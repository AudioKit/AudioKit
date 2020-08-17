// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKMoogLadderTests: AKTestCase {

    func testCutoffFrequency() {
        output = AKMoogLadder(input, cutoffFrequency: 500)
        AKTestMD5("f8a072dc406a73d9dbdd18f1affdd39f")
    }

    func testDefault() {
        output = AKMoogLadder(input)
        AKTestMD5("e9881ac2030dab7b083d19fd0a536d2b")
    }

    func testParameters() {
        output = AKMoogLadder(input, cutoffFrequency: 500, resonance: 0.9)
        AKTestMD5("983f6f432ad2e84c1d337f6900fdf257")
    }

    func testResonance() {
        output = AKMoogLadder(input, resonance: 0.9)
        AKTestMD5("846d7e6648e3252d6668b76a477371e2")
    }

}
