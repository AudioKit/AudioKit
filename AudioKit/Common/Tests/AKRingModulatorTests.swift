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
        let input = AKOscillator()
        output = AKRingModulator(input)
        input.start()
        AKTestMD5("3dddbc3f835b614b4c08a312e7c5670d")
    }
}
