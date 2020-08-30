// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKResonantFilterTests: AKTestCase2 {

    func testBandwidth() {
        output = AKResonantFilter(input, bandwidth: 500)
        AKTest()
    }

    func testDefault() {
        output = AKResonantFilter(input)
        AKTest()
    }

    func testFrequency() {
        output = AKResonantFilter(input, frequency: 1_000)
        AKTest()
    }

    func testParameters() {
        output = AKResonantFilter(input, frequency: 1_000, bandwidth: 500)
        AKTest()
    }

}
