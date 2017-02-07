//
//  AKModalResonanceFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKModalResonanceFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKModalResonanceFilter(input)
        input.start()
        AKTestMD5("9cd15a61ff271c2717bfb42a66e45c00")
    }
}
