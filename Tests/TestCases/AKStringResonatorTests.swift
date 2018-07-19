//
//  AKStringResonatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKStringResonatorTests: AKTestCase {

    func testBandwidth() {
        output = AKResonantFilter(input, bandwidth: 100)
        AKTestMD5("aa6aa3854202de9e8c3cb7ba554c8759")
    }

    func testDefault() {
        output = AKStringResonator(input)
        AKTestMD5("5fc8b14ba7b0df5076091e45b2f7b7b9")
    }

    func testFrequency() {
        output = AKResonantFilter(input, frequency: 500)
        AKTestMD5("2babbee0a60e94aae872efc10ecb60b4")
    }

    func testParameters() {
        output = AKResonantFilter(input, frequency: 500, bandwidth: 100)
        AKTestMD5("eef32378620a18fa71acb0d1af81f11b")
    }

}
