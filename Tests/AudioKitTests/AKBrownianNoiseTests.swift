// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBrownianNoiseTests: AKTestCase {

    func testDefault() {
        output = AKBrownianNoise()
        AKTest()
    }

    func testAmplitude() {
        output = AKBrownianNoise(amplitude: 0.5)
        AKTest()
    }

    func testAmplitude2() {
        let brown = AKBrownianNoise()
        brown.amplitude = 0.5
        output = brown
        AKTest()
    }
}
