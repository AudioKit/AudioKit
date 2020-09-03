// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        engine.output = AKToneFilter(input)
        AKTest()
    }

    func testHalfPowerPoint() {
        engine.output = AKToneFilter(input, halfPowerPoint: 599)
        AKTest()
    }
}
