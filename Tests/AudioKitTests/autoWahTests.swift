// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AutoWahTests: AKTestCase2 {

    func testAmplitude() {
        output = AKOperationEffect(input) { $0.autoWah(wah: 0.5, amplitude: 0.5) }
        AKTest()
    }

    func testDefault() {
        output = AKOperationEffect(input) { $0.autoWah() }
        AKTest()
    }

    func testWah() {
        output = AKOperationEffect(input) { $0.autoWah(wah: 0.5) }
        AKTest()
    }

}
