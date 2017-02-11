//
//  AKClipperTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKClipperTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKClipper(input)
        input.start()
        AKTestMD5("c29feeb240b68c3230dade9346c5b2cd")
    }
}
