//
//  smoothDelayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class smoothDelayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.smoothDelay(time: 0.1, maximumDelayTime: 0.1)
        }
        AKTestMD5("6ed22f8d4248c827f3ecb8b0e0e654de")
    }

}
