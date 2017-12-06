//
//  AKRingModulatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKRingModulatorTests: AKTestCase {

    func testDefault() {
        output = AKRingModulator(input)
        AKTestMD5("520a74712df06dddac638878d474010e")
    }
}
