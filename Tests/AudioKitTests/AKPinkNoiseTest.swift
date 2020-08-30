// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPinkNoiseTests: AKTestCase2 {

    let pink = AKPinkNoise()

    func testDefault() {
        output = pink
        pink.start()
        AKTest()
    }

    func testAmplitude() {
        pink.amplitude = 0.5
        output = pink
        pink.start()
        AKTest()
    }
}
