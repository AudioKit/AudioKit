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
        AKTestMD5("2ccbf0999bb5e10a63ae65936c6abd6d")
    }
    
    func testParameters2() {
        output = AKBooster2(input, gain: 0.5)
        AKTestMD5("11e2b5d6d79f802b47b84742a821406d")
    }
    
}

