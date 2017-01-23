//
//  AKAutoWahTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKAutoWahTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKAutoWah(input)
        input.start()
        AKTestMD5("30e9a7639b3af4f8159e307bf48a2844")
    }
}
