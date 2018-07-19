//
//  bitcrushTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import XCTest

class BitcrushTests: AKTestCase {

    func testBitDepth() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(bitDepth: 7)
        }
        AKTestMD5("f2a5fed76fdfb7f7e473e9339f24e2a4")
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush()
        }
        AKTestMD5("5ce9a59382eb0c16ddaf81438bce967b")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(bitDepth: 7, sampleRate: 4_000)
        }
        AKTestMD5("e6cbf0a4030d668f052b9ed5f6565676")
    }

    func testSampleRate() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(sampleRate: 4_000)
        }
        AKTestMD5("25f95095d33e528267e0d1aba377d621")
    }

}
