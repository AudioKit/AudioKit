// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPinkNoiseTests: AKTestCase {

    func testDefault() {
        output = AKPinkNoise()
        AKTest()
    }

    func testAmplitude() {
        output = AKPinkNoise(amplitude: 0.5)
        AKTest()
    }

    func testAmplitude2() {
        let pink = AKPinkNoise()
        pink.amplitude = 0.5
        output = pink
        AKTest()
    }
}
