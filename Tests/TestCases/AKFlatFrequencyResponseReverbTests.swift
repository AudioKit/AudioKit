// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKFlatFrequencyResponseReverbTests: AKTestCase {

    func testDefault() {
        output = AKFlatFrequencyResponseReverb(input)
        AKTestMD5("76324e03c74ad5654af5241f82acdadd")
    }

    func testLoopDuration() {
        output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1, loopDuration: 0.05)
        AKTestMD5("2fa598657c43a57ba8b149e124b9d647")
    }

    func testReverbDuration() {
        output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1)
        AKTestMD5("e53b197b557f751a35fbcf799c2bb70b")
    }
}
