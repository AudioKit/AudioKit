// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBitCrusherTests: AKTestCase {

    func testBitDepth() {
        output = AKBitCrusher(input, bitDepth: 12)
        AKTest()
    }

    func testBypass() {
        let crush = AKBitCrusher(input, bitDepth: 12)
        crush.bypass()
        output = crush
        AKTestNoEffect()
    }

    func testDefault() {
        output = AKBitCrusher(input)
        AKTest()
    }

    func testParameters() {
        output = AKBitCrusher(input, bitDepth: 12, sampleRate: 2_400)
        AKTest()
    }

    func testSampleRate() {
        output = AKBitCrusher(input, sampleRate: 2_400)
        AKTest()
    }

}
