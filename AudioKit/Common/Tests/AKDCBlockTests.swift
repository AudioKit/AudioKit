//
//  AKDCBlockTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKDCBlockTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKDCBlock(input)
        input.start()
        AKTestMD5("4b16ff791e9ab20f9692010ea814ddd1")
    }
}
