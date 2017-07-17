//
//  AKTremoloTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKTremoloTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKTremolo(input)
        input.start()
        AKTestMD5("818247cd8c1dee732a22633878ec81d4")
    }

    func testFrequency() {
        let input = AKOscillator()
        output = AKTremolo(input, frequency: 20)
        input.start()
        AKTestMD5("9509d8064efdd22d7d507a41cf97af17")
    }
}
