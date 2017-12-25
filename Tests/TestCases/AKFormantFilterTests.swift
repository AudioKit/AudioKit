//
//  AKFormantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKFormantFilterTests: AKTestCase {

    func testDefault() {
        output = AKFormantFilter(input)
        AKTestNoEffect()
    }
}
