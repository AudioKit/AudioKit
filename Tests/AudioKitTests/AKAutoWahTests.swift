// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKAutoWahTests: AKTestCase {

    func testAmplitude() {
        engine.output = AKAutoWah(input, wah: 0.123, amplitude: 0.789)
        AKTest()
    }

    func testBypass() {
        let wah = AKAutoWah(input, wah: 0.123, amplitude: 0.789)
        wah.bypass()
        engine.output = wah
        AKTestNoEffect()
    }

    func testDefault() {
        engine.output = AKAutoWah(input)
        AKTestNoEffect()
    }

    func testMix() {
        engine.output = AKAutoWah(input, wah: 0.123, mix: 0.456)
        AKTest()
    }

    func testParamters() {
        engine.output = AKAutoWah(input, wah: 0.123, mix: 0.456, amplitude: 0.789)
        AKTest()
    }

    func testWah() {
        engine.output = AKAutoWah(input, wah: 0.123)
        AKTest()
    }

}
