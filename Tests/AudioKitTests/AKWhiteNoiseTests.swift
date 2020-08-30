// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKWhiteNoiseTests: AKTestCase2 {

    let white = AKWhiteNoise()

    func testDefault() {
        output = white
        white.start()
        AKTest()
    }

    func testAmplitude() {
        white.amplitude = 0.5
        output = white
        white.start()
        AKTest()
    }
}
