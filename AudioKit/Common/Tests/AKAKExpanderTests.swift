//
//  AKExpanderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKExpanderTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKExpander(input)
        input.start()
        AKTestMD5("088edccae23805e40db383979c321064")
    }
}
