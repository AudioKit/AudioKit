// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKModalResonanceFilterTests: AKTestCase {

    func testDefault() {
        output = AKModalResonanceFilter(input)
        AKTest()
    }

    func testFrequency() {
        output = AKModalResonanceFilter(input, frequency: 400)
        AKTest()
    }

    func testParameters() {
        output = AKModalResonanceFilter(input, frequency: 400, qualityFactor: 66)
        AKTest()
    }

    func testQualityFactor() {
        output = AKModalResonanceFilter(input, qualityFactor: 66)
        AKTest()
    }
}
