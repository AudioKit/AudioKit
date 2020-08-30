// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKStringResonatorTests: AKTestCase2 {

    func testBandwidth() {
        output = AKResonantFilter(input, bandwidth: 100)
        AKTest()
    }

    func testDefault() {
        output = AKStringResonator(input)
        AKTest()
    }

    func testFrequency() {
        output = AKResonantFilter(input, frequency: 500)
        AKTest()
    }

    func testParameters() {
        output = AKResonantFilter(input, frequency: 500, bandwidth: 100)
        AKTest()
    }

}
