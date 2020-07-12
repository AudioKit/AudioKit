// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKWhiteNoiseTests: AKTestCase {

    func testDefault() {
        output = AKWhiteNoise()
        AKTestMD5("d6b3484278d57bc40ce66df5decb88be")
    }

    func testAmplitude() {
        output = AKWhiteNoise(amplitude: 0.5)
        AKTestMD5("18d62e4331862babc090ea8168c78d41")
    }

    func testAmplitude2() {
        let white = AKWhiteNoise()
        white.amplitude = 0.5
        output = white
        AKTestMD5("18d62e4331862babc090ea8168c78d41")
    }
}
