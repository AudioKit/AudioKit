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

    func testDefault() {
        output = AKAutoWah(input)
        AKTestNoEffect()
    }

    func testParamters() {
        output = AKAutoWah(input, wah: 0.123, mix: 0.456, amplitude: 0.789)
        AKTestMD5("061e71567837a66b15b18eb2c8ab2d25")
    }

    func testWah() {
        output = AKAutoWah(input, wah: 0.123)
        AKTestMD5("6a3b1ccbdb718be85ae1b76a2c578a43")
    }

    func testMix() {
        output = AKAutoWah(input, wah: 0.123, mix: 0.456)
        AKTestMD5("76df14881607b4fd4344a09264cfd249")
    }

    func testAmplitude() {
        output = AKAutoWah(input, wah: 0.123, amplitude: 0.789)
        AKTestMD5("bcbe1de4b3a467d1f423c1783c11588c")
    }

}
