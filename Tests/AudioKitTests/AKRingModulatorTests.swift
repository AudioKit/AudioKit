// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKRingModulatorTests: AKTestCase2 {

    func testDefault() {
        output = AKRingModulator(input)
        AKTest()
    }
}
