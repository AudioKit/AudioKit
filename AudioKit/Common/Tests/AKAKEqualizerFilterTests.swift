//
//  AKEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKEqualizerFilter(input)
        input.start()
        AKTestMD5("36ab560e2df34c8ec3946eabf5d4fccb")
    }
}
