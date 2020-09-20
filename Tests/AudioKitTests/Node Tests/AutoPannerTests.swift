// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AutoPannerTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator()
        engine.output = AutoPanner(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDepth() {
        let engine = AudioEngine()
        let input = Oscillator()
        engine.output = AutoPanner(input, depth: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AudioEngine()
        let input = Oscillator()
        engine.output = AutoPanner(input, frequency: 20)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator()
        engine.output = AutoPanner(input, frequency: 20, depth: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
