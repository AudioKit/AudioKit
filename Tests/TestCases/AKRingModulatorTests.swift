//
//  AKRingModulatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKRingModulatorTests: AKTestCase {

    func testDefault() {
        output = AKRingModulator(input)
        AKTestMD5("520a74712df06dddac638878d474010e")
    }
}
