//
//  AKStringResonatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKStringResonatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKStringResonator(input)
        input.start()
        AKTestMD5("e7c52eedcf58d0a0990a4faace230621")
    }
}
