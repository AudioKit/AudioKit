// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AutoWahTests: AKTestCase {

    func testAmplitude() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah(wah: 0.5, amplitude: 0.5)
        }
        AKTest()
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah()
        }
        AKTest()
    }

    func testWah() {
        output = AKOperationEffect(input) { input, _ in
            return input.autoWah(wah: 0.5)
        }
        AKTest()
    }

}
