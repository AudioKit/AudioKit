//
//  AKResonantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKResonantFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKResonantFilter(input)
        input.start()
        AKTestMD5("90c0b421eeb4d967f9081fa061bf9e0f")
    }
}
