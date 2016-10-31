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
        AKTestMD5("e5703dc7c9a0f138261a0007c2f9cab9")
    }
}
