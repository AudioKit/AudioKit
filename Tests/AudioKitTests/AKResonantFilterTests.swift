// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKResonantFilterTests: AKTestCase {

    func testBandwidth() {
        engine.output = AKResonantFilter(input, bandwidth: 500)
        AKTest()
    }

    func testDefault() {
        engine.output = AKResonantFilter(input)
        AKTest()
    }

    func testFrequency() {
        engine.output = AKResonantFilter(input, frequency: 1_000)
        AKTest()
    }

    func testParameters() {
        engine.output = AKResonantFilter(input, frequency: 1_000, bandwidth: 500)
        AKTest()
    }

}
