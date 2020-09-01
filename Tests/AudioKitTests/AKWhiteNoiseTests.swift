// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKWhiteNoiseTests: AKTestCase {

    let white = AKWhiteNoise()

    func testDefault() {
        engine.output = white
        white.start()
        AKTest()
    }

    func testAmplitude() {
        white.amplitude = 0.5
        engine.output = white
        white.start()
        AKTest()
    }
}
