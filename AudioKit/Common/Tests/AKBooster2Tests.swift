//
//  AKBooster2Tests.swift
//  AudioKitTestSuiteTests
//
//  Created by Aurelius Prochazka on 11/22/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBooster2Tests: AKTestCase {
    
    func testDefault() {
        output = AKBooster2(input)
        AKTestNoEffect()
    }
    
    func testParameters() {
        output = AKBooster2(input, gain: 2.0)
        AKTestMD5("09fdb24adb3181f6985eba4b408d8c6d")
    }
    
    func testParameters2() {
        output = AKBooster2(input, gain: 0.5)
        AKTestMD5("79972090508032a146d806185f9bc871")
    }
}

