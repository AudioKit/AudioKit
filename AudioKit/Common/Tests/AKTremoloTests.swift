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
        output = AKTremolo(input)
        AKTestMD5("818247cd8c1dee732a22633878ec81d4")
    }

    func testFrequency() {
        output = AKTremolo(input, frequency: 20)
        AKTestMD5("9509d8064efdd22d7d507a41cf97af17")
    }
}
