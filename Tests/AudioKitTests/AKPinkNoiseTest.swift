// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPinkNoiseTests: AKTestCase {

    let pink = AKPinkNoise()

    func testDefault() {
        engine.output = pink
        pink.start()
        AKTest()
    }

    func testAmplitude() {
        pink.amplitude = 0.5
        engine.output = pink
        pink.start()
        AKTest()
    }
}
