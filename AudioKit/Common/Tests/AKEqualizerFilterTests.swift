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
        AKTestMD5("6c24d57088b7f1208a8d308b1fe7b1ce")
    }
}
