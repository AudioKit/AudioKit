//
//  reverberateWithFlatFrequencyResponseTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest

import AudioKit

class reverberateWithFlatFrequencyResponseTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testDefault() {
        let input = AKOscillator()
        input.start()
        output = AKOperationEffect(input) { input, _ in
            return input.reverberateWithFlatFrequencyResponse()
        }
        AKTestMD5("cc67d104a3c890199cb5c21cd4c019de")
    }

}
