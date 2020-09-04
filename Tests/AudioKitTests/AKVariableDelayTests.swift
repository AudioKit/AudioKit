// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKVariableDelayTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKVariableDelay(input)
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testFeedback() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKVariableDelay(input, feedback: 0.95)
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testMaximum() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKVariableDelay(input, time: 0.02, feedback: 0.8, maximumTime: 0.02)
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testMaximumSurpassed() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKVariableDelay(input, time: 0.03, feedback: 0.8, maximumTime: 0.02)
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testParametersSetAfterInit() {
        let engine = AKEngine()
        let input = AKOscillator()
        let effect = AKVariableDelay(input)
        effect.time = 0.123_4
        effect.feedback = 0.95
        engine.output = effect
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testParametersSetOnInit() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKVariableDelay(input, time: 0.123_4, feedback: 0.95)
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testTime() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKVariableDelay(input, time: 0.123_4)
        input.start()
        let audio = engine.startTest(totalDuration: 5.0)
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

}
