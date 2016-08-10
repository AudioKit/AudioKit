//
//  AKRingModulatorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
@testable import AudioKit

class AKRingModulatorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKRingModulator(input)
        input.start()
        AKTestMD5("b8c2dbcb323e4b2cfa21207830f45a40", alternate: "4cd72c9b6398a8b7dcd1f5e7966c66f2")
    }
}
