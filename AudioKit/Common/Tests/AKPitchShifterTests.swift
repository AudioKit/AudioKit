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
        AKTestMD5("65f31d2baea77e7a16e6558f56bf1741")
    }
}
