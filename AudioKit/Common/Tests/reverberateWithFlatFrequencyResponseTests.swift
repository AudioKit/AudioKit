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
        AKTestMD5("c4d24a25085c972e54a290ba7367ef18")
    }

}
