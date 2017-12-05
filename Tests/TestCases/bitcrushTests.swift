//
//  bitcrushTests.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class BitcrushTests: AKTestCase {

    func testBitDepth() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(bitDepth: 7)
        }
        AKTestMD5("c52698781b056e8317465dbce6904523")
    }

    func testDefault() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush()
        }
        AKTestMD5("6f7a0ae3e6f604e1b8c44a41138eb7f4")
    }

    func testParameters() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(bitDepth: 7, sampleRate: 4_000)
        }
        AKTestMD5("bebe7bbf6e1df77cc78595093b4751e0")
    }

    func testSampleRate() {
        output = AKOperationEffect(input) { input, _ in
            return input.bitCrush(sampleRate: 4_000)
        }
        AKTestMD5("4ec24d4f76114f2ce4889f5e8c8fff3e")
    }

}
