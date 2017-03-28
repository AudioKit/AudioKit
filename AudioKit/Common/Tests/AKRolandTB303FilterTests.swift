//
//  AKRolandTB303FilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKRolandTB303FilterTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKRolandTB303Filter(input)
        input.start()
        AKTestMD5("0f8345a5be46169f37d5650dc01f8ffa")
    }
}
