// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDynamicRangeCompressorTests: AKTestCase {

    override func setUp() {
        super.setUp()
        // Need to have a longer test duration to allow for envelope to progress
        duration = 1.0
        input.rampDuration = 0.0
        input.amplitude = 2.0
   }

    func testAttackDuration() {
        output = AKDynamicRangeCompressor(input, ratio: 0.5, attackDuration: 0.2)
        AKTest()
    }

    func testDefault() {
        output = AKDynamicRangeCompressor(input)
        AKTest()
    }

    func testParameters() {
        output = AKDynamicRangeCompressor(input,
                                          ratio: 0.5,
                                          threshold: -1,
                                          attackDuration: 0.2,
                                          releaseDuration: 0.2)
        AKTest()
    }

    func testRatio() {
        output = AKDynamicRangeCompressor(input, ratio: 0.5)
        AKTest()
    }

    func testReleaseDuration() {
        output = AKDynamicRangeCompressor(input, ratio: 0.5, releaseDuration: 0.2)
        AKTest()
    }

    func testThreshold() {
        output = AKDynamicRangeCompressor(input, ratio: 0.5, threshold: -1)
        AKTest()
    }

}
