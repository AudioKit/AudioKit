//
//  AKStringResonatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKStringResonatorTests: AKTestCase {

    func testDefault() {
        output = AKStringResonator(input)
        AKTestMD5("82e87c2d67c4c79e29d3a49979858c11")
    }

    func testParameters() {
        output = AKResonantFilter(input, frequency: 500, bandwidth: 100)
        AKTestMD5("8717b10fc4302b77268594bf4824572e")
    }

    func testFrequency() {
        output = AKResonantFilter(input, frequency: 500)
        AKTestMD5("d5e3678658a738e2c59fa107168f80e7")
    }

    func testBandwidth() {
        output = AKResonantFilter(input, bandwidth: 100)
        AKTestMD5("87266783be2532b3d69022644635c350")
    }
}
