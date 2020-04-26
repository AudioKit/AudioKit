// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        output = AKToneFilter(input)
        AKTestMD5("c8e4d376f935ac52046d3b23a19024ba")
    }

    func testHalfPowerPoint() {
        output = AKToneFilter(input, halfPowerPoint: 599)
        AKTestMD5("ce9a025c219731a670522a33057d4e64")
    }
}
