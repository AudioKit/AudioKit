// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKRingModulatorTests: AKTestCase {

    func testDefault() {
        engine.output = AKRingModulator(input)
        AKTest()
    }
}
