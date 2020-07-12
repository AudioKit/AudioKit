// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKPinkNoiseTests: AKTestCase {

    func testDefault() {
        output = AKPinkNoise()
        AKTestMD5("b56ddd343583e6e58b559d10b8b4c147")
    }

    func testAmplitude() {
        output = AKPinkNoise(amplitude: 0.5)
        AKTestMD5("a30e01dd9169d41be4d0ae5c5896e0bd")
    }

    func testAmplitude2() {
        let pink = AKPinkNoise()
        pink.amplitude = 0.5
        output = pink
        AKTestMD5("a30e01dd9169d41be4d0ae5c5896e0bd")
    }
}
