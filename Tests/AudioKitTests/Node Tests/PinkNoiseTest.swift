// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PinkNoiseTests: XCTestCase {


    func testDefault() {
        let engine = AudioEngine()
        let pink = PinkNoise()
        engine.output = pink
        pink.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AudioEngine()
        let pink = PinkNoise()
        pink.amplitude = 0.5
        engine.output = pink
        pink.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
