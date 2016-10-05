//
//  AKParametricEQTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKParametricEQTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKParametricEQ(input)
        input.start()
        AKTestMD5("4440a371b1f0fb002ede8a5367b78668")
    }
}
