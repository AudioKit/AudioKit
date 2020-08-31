// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKToneComplementFilterTests: AKTestCase {

    func testDefault() {
        output = AKToneComplementFilter(input)
        AKTest()
    }

    func testHalfPowerPoint() {
        output = AKToneComplementFilter(input, halfPowerPoint: 500)
        AKTest()
    }
}
