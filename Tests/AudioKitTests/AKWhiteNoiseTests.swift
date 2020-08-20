// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKWhiteNoiseTests: AKTestCase {

    func testDefault() {
        output = AKWhiteNoise()
        AKTest()
    }

    func testAmplitude() {
        output = AKWhiteNoise(amplitude: 0.5)
        AKTest()
    }

    func testAmplitude2() {
        let white = AKWhiteNoise()
        white.amplitude = 0.5
        output = white
        AKTest()
    }
}
