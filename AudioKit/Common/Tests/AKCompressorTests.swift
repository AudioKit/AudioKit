//
//  AKCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import XCTest
import AudioKit

class AKCompressorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKCompressor(input)
        input.start()
        AKTestMD5("035ab56a28646a8168dd92df8f92efc9", alternate: "a39edf51b73abdc2d6a179ff5ebb8792")
    }
}
