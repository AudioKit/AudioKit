//
//  AKModalResonanceFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKModalResonanceFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKModalResonanceFilter(input)
        input.start()
        AKTestMD5("9cd15a61ff271c2717bfb42a66e45c00")
    }
}
