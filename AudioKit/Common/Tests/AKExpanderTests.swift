//
//  AKExpanderTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKExpanderTests: AKTestCase {

    func testDefault() {
        output = AKExpander(input)
        AKTestMD5("c306ea48f9c121183c99c7b3396c96fc")
    }
}
