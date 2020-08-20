// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKHighShelfFilterTests: AKTestCase {

    func testDefault() {
        output = AKHighShelfFilter(input)
        AKTestNoEffect()
    }

    func testGain() {
        output = AKHighShelfFilter(input, gain: 1)
        AKTest()
    }

    func testParameters() {
        output = AKHighShelfFilter(input, cutOffFrequency: 400, gain: 1)
        AKTest()
    }

}
