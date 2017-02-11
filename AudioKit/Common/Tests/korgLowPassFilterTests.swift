//
//  korgLowPassFilterTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class korgLowPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.korgLowPassFilter()
        }
        AKTestMD5("d2d404096ebe8a473e0b547c4a9898ec")
    }

    func testParameters() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.korgLowPassFilter(cutoffFrequency: 2_000, resonance: 0.9, saturation: 0.5)
        }
        AKTestMD5("7723ef0eef2decc29c88696f11f98a9c")
    }

}
