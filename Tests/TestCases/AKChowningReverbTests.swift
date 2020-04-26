// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKChowningReverbTests: AKTestCase {

    func testActuallyProcessing() {
        input = AKOscillator(waveform: AKTable(.square))
        output = input
        AKTestMD5Not("038cb0338d1615e9a5d7c2750f24e6da")
    }

    func testDefault() {
        output = AKChowningReverb(input)
        AKTestMD5("e0fccf8b15ddbc286c73bdcffdfd7c9b")
    }

}
