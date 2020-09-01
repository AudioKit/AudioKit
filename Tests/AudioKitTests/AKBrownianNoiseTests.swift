// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKBrownianNoiseTests: AKTestCase {

    let brown = AKBrownianNoise()

    func testDefault() {
        engine.output = brown
        brown.start()
        AKTest()
    }

    func testAmplitude() {

        brown.amplitude = 0.5
        engine.output = brown
        brown.start()
        AKTest()
    }
}
