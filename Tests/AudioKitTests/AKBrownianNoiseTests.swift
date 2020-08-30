// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBrownianNoiseTests: AKTestCase2 {

    let brown = AKBrownianNoise()

    func testDefault() {
        output = brown
        brown.start()
        AKTest()
    }

    func testAmplitude() {

        brown.amplitude = 0.5
        output = brown
        brown.start()
        AKTest()
    }
}
