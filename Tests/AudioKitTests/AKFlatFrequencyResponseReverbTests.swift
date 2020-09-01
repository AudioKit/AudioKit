// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        engine.output = AKFlatFrequencyResponseReverb(input)
        AKTest()
    }

    func testLoopDuration() {
        engine.output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1, loopDuration: 0.05)
        AKTest()
    }

    func testReverbDuration() {
        engine.output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1)
        AKTest()
    }
}
