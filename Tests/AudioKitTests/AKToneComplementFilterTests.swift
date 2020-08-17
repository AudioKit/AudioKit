// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKToneComplementFilterTests: AKTestCase {

    func testDefault() {
        output = AKToneComplementFilter(input)
        AKTestMD5("666ebfe690f1f76d4bc0917fff9ae1f8")
    }

    func testHalfPowerPoint() {
        output = AKToneComplementFilter(input, halfPowerPoint: 500)
        AKTestMD5("ac3cbc24c7f419e207081174f5eabf9f")
    }
}
