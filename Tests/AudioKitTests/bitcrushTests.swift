// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class BitcrushTests: AKTestCase {

    func testBitDepth() {
        output = AKOperationEffect(input) { $0.bitCrush(bitDepth: 7) }
        AKTest()
    }

    func testDefault() {
        output = AKOperationEffect(input) { $0.bitCrush() }
        AKTest()
    }

    func testParameters() {
        output = AKOperationEffect(input) { $0.bitCrush(bitDepth: 7, sampleRate: 4_000) }
        AKTest()
    }

    func testSampleRate() {
        output = AKOperationEffect(input) { $0.bitCrush(sampleRate: 4_000) }
        AKTest()
    }

}
