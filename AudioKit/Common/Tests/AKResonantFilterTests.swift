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
        let input = AKOscillator()
        output = AKResonantFilter(input)
        input.start()
        AKTestMD5("90c0b421eeb4d967f9081fa061bf9e0f")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKResonantFilter(input, frequency: 1000, bandwidth: 500)
        input.start()
        AKTestMD5("71418107bbd1efbda3cef4c8e49a6971")
    }

    func testFrequency() {
        let input = AKOscillator()
        output = AKResonantFilter(input, frequency: 1000)
        input.start()
        AKTestMD5("0376ea4eace86e3fe6a5041dff6f6045")
    }

    func testBandwidth() {
        let input = AKOscillator()
        output = AKResonantFilter(input, bandwidth: 500)
        input.start()
        AKTestMD5("4af1c60c1058c6dfc5bb94494354eccc")
    }
}
