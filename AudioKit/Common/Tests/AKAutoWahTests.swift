//
//  AKAutoWahTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKAutoWahTests: AKTestCase {

    func testAmplitude() {
        output = AKAutoWah(input, wah: 0.123, amplitude: 0.789)
        AKTestMD5("82afa0cb12a180631ace15f11c9c94ef")
    }

    func testDefault() {
        output = AKAutoWah(input)
        AKTestNoEffect()
    }

    func testMix() {
        output = AKAutoWah(input, wah: 0.123, mix: 0.456)
        AKTestMD5("5f7efbc76cae8c392fe0b4a7b70ef855")
    }

    func testParamters() {
        output = AKAutoWah(input, wah: 0.123, mix: 0.456, amplitude: 0.789)
        AKTestMD5("489197d654ce3fb79c802e05e51e4558")
    }

    func testWah() {
        output = AKAutoWah(input, wah: 0.123)
        AKTestMD5("5d2f580b18e37f24b497328dddeb5721")
    }

}
