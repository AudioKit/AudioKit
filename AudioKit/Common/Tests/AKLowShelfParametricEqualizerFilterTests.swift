//
//  AKLowShelfParametricEqualizerFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKLowShelfParametricEqualizerFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKLowShelfParametricEqualizerFilter(input)
        input.start()
        AKTestMD5("56c1b9e1b8509124b8365b707fb05321")
    }
}
