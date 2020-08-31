// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import Foundation

class AKCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testAttackDuration() {
        output = AKCompressor(input, attackDuration: 0.1)
        AKTest()
    }

    func testDefault() {
        output = AKCompressor(input)
        AKTest()
    }

    func testHeadRoom() {
        output = AKCompressor(input, headRoom: 0)
        AKTest()
    }

    func testMasterGain() {
        output = AKCompressor(input, masterGain: 1)
        AKTest()
    }

    func testParameters() {
        output = AKCompressor(input,
                              threshold: -25,
                              headRoom: 10,
                              attackDuration: 0.1,
                              releaseDuration: 0.1,
                              masterGain: 1)
        AKTest()
    }

    // Release time is not currently tested

    func testThreshold() {
        output = AKCompressor(input, threshold: -25)
        AKTest()
    }

}
