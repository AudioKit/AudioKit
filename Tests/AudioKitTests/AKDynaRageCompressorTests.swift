// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

// TODO: Test was left out of old test suite.
#if false

class AKDynaRangeCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
        input.rampDuration = 0.0
        input.amplitude = 0.1
    }

    func testAttackTime() {
        engine.output = AKDynaRageCompressor(input, ratio: 10, attackDuration: 21)
        AKTest()
    }

    func testDefault() {
        engine.output = AKDynaRageCompressor(input)
        AKTest()
    }

    func testParameters() {
        engine.output = AKDynaRageCompressor(input,
                                      ratio: 10,
                                      threshold: -1,
                                      attackDuration: 21,
                                      releaseDuration: 22)
        AKTest()
    }

    func testRage() {
        engine.output = AKDynaRageCompressor(input, ratio: 10, rage: 10)
        AKTest()
    }

    func testRatio() {
        engine.output = AKDynaRageCompressor(input, ratio: 10)
        AKTest()
    }

    func testReleaseTime() {
        engine.output = AKDynaRageCompressor(input, ratio: 10, releaseDuration: 22)
        AKTest()
    }

    func testThreshold() {
        engine.output = AKDynaRageCompressor(input, ratio: 10, threshold: -1)
        AKTest()
    }

}

#endif
