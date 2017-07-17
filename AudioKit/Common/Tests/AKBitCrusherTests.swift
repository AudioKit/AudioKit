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

    func testDefault() {
        let input = AKOscillator()
        output = AKBitCrusher(input)
        input.start()
        AKTestMD5("801dc339290c62b79f18ae22828ee665")
    }

    func testParameters() {
        let input = AKOscillator()
        output = AKBitCrusher(input, bitDepth: 12, sampleRate: 2400)
        input.start()
        AKTestMD5("016a569c401187b65a8f9e6e5680c27a")
    }

    func testBitDepth() {
        let input = AKOscillator()
        output = AKBitCrusher(input, bitDepth: 12)
        input.start()
        AKTestMD5("88eb95a6c826ddafd6e3e33f660ec99d")
    }


    func testSampleRate() {
        let input = AKOscillator()
        output = AKBitCrusher(input, sampleRate: 2400)
        input.start()
        AKTestMD5("84fcd2b2368aa607c644c9131f568285")
    }

}
