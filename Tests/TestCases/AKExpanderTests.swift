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
        AKTestMD5("b118304cd9c733200b0e2b6f99a41efa")
    }
}
