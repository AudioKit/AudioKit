//
//  AKFormantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKFormantFilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKFormantFilter(input)
        input.start()
        AKTestMD5("c25be5e2cc72f67f53453f15b892ba65")
    }
}
