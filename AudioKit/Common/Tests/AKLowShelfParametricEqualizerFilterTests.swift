//
//  AKLowShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKLowShelfParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("fe5cdbf4b76e8d2c26c10ef8f93b042e")
    }
}
