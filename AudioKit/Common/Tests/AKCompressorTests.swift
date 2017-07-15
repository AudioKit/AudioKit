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

    func testParameters1() {
        let input = AKOscillator()
        output = AKCompressor(input,
                              threshold: -25,
                              headRoom: 10,
                              attackTime: 0.1,
                              releaseTime: 0.1,
                              masterGain: 1)
        input.start()
        AKTestMD5("e83f89c8249e4044639328b7fad55628")
    }

    func testParameters2() {
        let input = AKOscillator()
        output = AKCompressor(input,
                              threshold: -30,
                              headRoom: 20,
                              attackTime: 0.01,
                              releaseTime: 0.01,
                              masterGain: -1)
        input.start()
        AKTestMD5("7ca40d7ff9964ceca52edc9835379a56")
    }

}
