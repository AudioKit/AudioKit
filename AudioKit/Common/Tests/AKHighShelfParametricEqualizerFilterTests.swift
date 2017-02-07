//
//  AKHighShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKHighShelfParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKHighShelfParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("907b6c2c83772318a8bee5abac56249c")
    }
}
