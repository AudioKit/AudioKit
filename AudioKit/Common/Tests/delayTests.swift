//
//  delayTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class delayTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.delay(time: 0.1, feedback: 0.9)
        }
        AKTestMD5("c26b72e6fd0e4a96edf1d8dbbbd05895")
    }

}
