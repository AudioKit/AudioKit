//
//  AKBitCrusherTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKBitCrusherTests: AKTestCase {

    func testBitDepth() {
        output = AKBitCrusher(input, bitDepth: 12)
        AKTestMD5("7e4e26543bfeb6830406b874f58f57a5")
    }

    func testDefault() {
        output = AKBitCrusher(input)
        AKTestMD5("d99f3c969dec97f03816dac30ba56b20")
    }

    func testParameters() {
        output = AKBitCrusher(input, bitDepth: 12, sampleRate: 2_400)
        AKTestMD5("60dfa342cb1606f71904a1628f5a2930")
    }

    func testSampleRate() {
        output = AKBitCrusher(input, sampleRate: 2_400)
        AKTestMD5("03727f2b8b756bee9a85bcdea7b3e10b")
    }

}
