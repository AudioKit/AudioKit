// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        output = AKFlatFrequencyResponseReverb(input)
        AKTest()
    }

    func testLoopDuration() {
        output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1, loopDuration: 0.05)
        AKTest()
    }

    func testReverbDuration() {
        output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1)
        AKTest()
    }
}
