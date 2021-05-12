// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class BrownianNoiseTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let brown = BrownianNoise()
        engine.output = brown
        brown.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AudioEngine()
        let brown = BrownianNoise()
        brown.amplitude = 0.5
        engine.output = brown
        brown.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testGeneric() {
        testMD5(generatorNodeRandomizedTest(factory: { BrownianNoise() }))
    }
}
