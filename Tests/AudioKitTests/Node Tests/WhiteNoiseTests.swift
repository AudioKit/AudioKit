// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKWhiteNoiseTests: XCTestCase {
    func testDefault() {
        let engine = AKEngine()
        let white = AKWhiteNoise()
        engine.output = white
        white.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AKEngine()
        let white = AKWhiteNoise()
        white.amplitude = 0.5
        engine.output = white
        white.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
