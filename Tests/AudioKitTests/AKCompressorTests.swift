// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import Foundation

class AKCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testAttackDuration() {
        engine.output = AKCompressor(input, attackDuration: 0.1)
        AKTest()
    }

    func testDefault() {
        engine.output = AKCompressor(input)
        AKTest()
    }

    func testHeadRoom() {
        engine.output = AKCompressor(input, headRoom: 0)
        AKTest()
    }

    func testMasterGain() {
        engine.output = AKCompressor(input, masterGain: 1)
        AKTest()
    }

    func testParameters() {
        engine.output = AKCompressor(input,
                              threshold: -25,
                              headRoom: 10,
                              attackDuration: 0.1,
                              releaseDuration: 0.1,
                              masterGain: 1)
        AKTest()
    }

    // Release time is not currently tested

    func testThreshold() {
        engine.output = AKCompressor(input, threshold: -25)
        AKTest()
    }

}
