// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKRingModulatorTests: AKTestCase {

    func testDefault() {
        output = AKRingModulator(input)
        AKTestMD5("520a74712df06dddac638878d474010e")
    }
}
