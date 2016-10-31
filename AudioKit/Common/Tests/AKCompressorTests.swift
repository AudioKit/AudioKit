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
        AKTestMD5("cf12ea8dbbe0a1bee2c4c83956c61a49")
    }
}
