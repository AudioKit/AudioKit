//
//  AKBitCrusherTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class AKBitCrusherTests: AKTestCase {

    func testBitDepth() {
        output = AKBitCrusher(input, bitDepth: 12)
        AKTestMD5("4903010e3f4e3b933870cbdf0dd85c9b")
    }

    func testBypass() {
        let crush = AKBitCrusher(input, bitDepth: 12)
        crush.bypass()
        output = crush
        AKTestNoEffect()
    }

    func testDefault() {
        output = AKBitCrusher(input)
        AKTestMD5("fb92c496b84bb0e9d77ce35ec3effa95")
    }

    func testParameters() {
        output = AKBitCrusher(input, bitDepth: 12, sampleRate: 2_400)
        AKTestMD5("c0afe756aa4f5a36e5721685993b8217")
    }

    func testSampleRate() {
        output = AKBitCrusher(input, sampleRate: 2_400)
        AKTestMD5("41b449c15a706f5e3c4ecdc5ae2a74cf")
    }

}
