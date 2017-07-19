//
//  AKToneComplementFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKToneComplementFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKToneComplementFilter(input)
        input.start()
        AKTestMD5("00dab98d5e1e1d2febb5e036dd96d497")
    }

    func testHalfPowerPoint() {
        let input = AKOscillator()
        output = AKToneComplementFilter(input, halfPowerPoint: 500)
        input.start()
        AKTestMD5("0cf0221f8bd572309f7499f62ee18bba")
    }
}
