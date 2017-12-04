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
        AKTestMD5("786f65133d587399be35aa789e287815")
    }

    func testDefault() {
        output = AKAutoWah(input)
        AKTestNoEffect()
    }

    func testMix() {
        output = AKAutoWah(input, wah: 0.123, mix: 0.456)
        AKTestMD5("564135c992b22da1afc7115d5efd2831")
    }

    func testParamters() {
        output = AKAutoWah(input, wah: 0.123, mix: 0.456, amplitude: 0.789)
        AKTestMD5("7c9b38d3ff498b7f707644f85b18e60c")
    }

    func testWah() {
        output = AKAutoWah(input, wah: 0.123)
        AKTestMD5("221729db45a1088330ea7ffffd466780")
    }

}
