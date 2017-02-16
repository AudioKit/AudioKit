//
//  AKCompressorTests.swift
//  AudioKitTestSuite
//
//  Created by Aurelius Prochazka on 8/9/16.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import AudioKit
import XCTest

class AKCompressorTests: AKTestCase {

    func testDefault() {
        let input = AKOscillator()
        output = AKCompressor(input)
        input.start()
        AKTestMD5("cf12ea8dbbe0a1bee2c4c83956c61a49")
    }
}
