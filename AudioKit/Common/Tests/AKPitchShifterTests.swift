//
//  AKPitchShifterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKPitchShifterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPitchShifter(input)
        input.start()
        AKTestMD5("dfa1505b44737bdcaa4834587eae3c07")
    }
}
