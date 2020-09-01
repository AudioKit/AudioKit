// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKStringResonatorTests: AKTestCase {

    func testBandwidth() {
        engine.output = AKResonantFilter(input, bandwidth: 100)
        AKTest()
    }

    func testDefault() {
        engine.output = AKStringResonator(input)
        AKTest()
    }

    func testFrequency() {
        engine.output = AKResonantFilter(input, frequency: 500)
        AKTest()
    }

    func testParameters() {
        engine.output = AKResonantFilter(input, frequency: 500, bandwidth: 100)
        AKTest()
    }

}
