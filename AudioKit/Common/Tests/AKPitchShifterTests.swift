//
//  AKPitchShifterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKPitchShifterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKPitchShifter(input)
        input.start()
        AKTestMD5("c49a3cb36261a3e8e45a59b90899628c")
    }
}
