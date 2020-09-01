// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AutoWahTests: AKTestCase {

    func testAmplitude() {
        engine.output = AKOperationEffect(input) { $0.autoWah(wah: 0.5, amplitude: 0.5) }
        AKTest()
    }

    func testDefault() {
        engine.output = AKOperationEffect(input) { $0.autoWah() }
        AKTest()
    }

    func testWah() {
        engine.output = AKOperationEffect(input) { $0.autoWah(wah: 0.5) }
        AKTest()
    }

}
