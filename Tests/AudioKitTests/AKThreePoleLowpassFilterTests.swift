// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKThreePoleLowpassFilterTests: XCTestCase {

    func testCutoffFrequency() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKThreePoleLowpassFilter(input, cutoffFrequency: 500)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKThreePoleLowpassFilter(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDistortion() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKThreePoleLowpassFilter(input, distortion: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKThreePoleLowpassFilter(input, distortion: 1, cutoffFrequency: 500, resonance: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testResonance() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKThreePoleLowpassFilter(input, resonance: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
