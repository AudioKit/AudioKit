//
//  AKPitchShifterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKPitchShifterTests: AKTestCase {

    func testCrossfade() {
        output = AKPitchShifter(input, shift: 7, crossfade: 1_024)
        AKTestMD5("c43f5dba443189efe91660c094b675b6")
    }

    func testDefault() {
        output = AKPitchShifter(input)
        AKTestMD5("c40c145c37584e171b0cc4ffa5008d98")
    }

    func testParameters() {
        output = AKPitchShifter(input, shift: 7, windowSize: 2_048, crossfade: 1_024)
        AKTestMD5("c07f5d73e08d46f0e89d1ef5d9bfe371")
    }

    func testShift() {
        output = AKPitchShifter(input, shift: 7)
        AKTestMD5("0b32767c8ae3798755c4f99e62d03754")
    }

    func testWindowSize() {
        output = AKPitchShifter(input, shift: 7, windowSize: 2_048)
        AKTestMD5("6c3673e5fc317093a8d91f7f449b2b26")
    }

}
