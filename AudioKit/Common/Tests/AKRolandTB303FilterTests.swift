//
//  AKRolandTB303FilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKRolandTB303FilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input)
        input.start()
        AKTestMD5("0f8345a5be46169f37d5650dc01f8ffa")
    }
}
