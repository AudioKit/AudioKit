//
//  AKToneFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKToneFilterTests: AKTestCase {

    func testDefault() {
        output = AKToneFilter(input)
        AKTestMD5("c8e4d376f935ac52046d3b23a19024ba")
    }

    func testHalfPowerPoint() {
        output = AKToneFilter(input, halfPowerPoint: 599)
        AKTestMD5("ce9a025c219731a670522a33057d4e64")
    }
}
