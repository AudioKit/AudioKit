//
//  AKResonantFilterTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKResonantFilterTests: AKTestCase {

    func testDefault() {
        output = AKResonantFilter(input)
        AKTestMD5("90c0b421eeb4d967f9081fa061bf9e0f")
    }

    func testParameters() {
        output = AKResonantFilter(input, frequency: 1000, bandwidth: 500)
        AKTestMD5("71418107bbd1efbda3cef4c8e49a6971")
    }

    func testFrequency() {
        output = AKResonantFilter(input, frequency: 1000)
        AKTestMD5("0376ea4eace86e3fe6a5041dff6f6045")
    }

    func testBandwidth() {
        output = AKResonantFilter(input, bandwidth: 500)
        AKTestMD5("4af1c60c1058c6dfc5bb94494354eccc")
    }
}
