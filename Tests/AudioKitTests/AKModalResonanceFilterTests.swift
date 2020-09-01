// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKModalResonanceFilterTests: AKTestCase {

    func testDefault() {
        engine.output = AKModalResonanceFilter(input)
        AKTest()
    }

    func testFrequency() {
        engine.output = AKModalResonanceFilter(input, frequency: 400)
        AKTest()
    }

    func testParameters() {
        engine.output = AKModalResonanceFilter(input, frequency: 400, qualityFactor: 66)
        AKTest()
    }

    func testQualityFactor() {
        engine.output = AKModalResonanceFilter(input, qualityFactor: 66)
        AKTest()
    }
}
