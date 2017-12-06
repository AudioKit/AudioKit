//
//  korgLowPassFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class KorgLowPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.korgLowPassFilter()
        }
        AKTestMD5("aeb433486d45f43ca56fc2129b6e139b")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.korgLowPassFilter(cutoffFrequency: 2_000, resonance: 0.9, saturation: 0.5)
        }
        AKTestMD5("a4acbe1dd84c0075659f10f9e48d45dd")
    }

}
