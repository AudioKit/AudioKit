// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        output = AKToneFilter(input)
        AKTest()
    }

    func testHalfPowerPoint() {
        output = AKToneFilter(input, halfPowerPoint: 599)
        AKTest()
    }
}
