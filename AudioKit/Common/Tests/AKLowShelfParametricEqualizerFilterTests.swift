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
        AKTestMD5("56c1b9e1b8509124b8365b707fb05321")
    }
}
