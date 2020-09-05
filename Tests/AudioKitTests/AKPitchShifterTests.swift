// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPitchShifterTests: XCTestCase {

    func testCrossfade() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPitchShifter(input, shift: 7, crossfade: 1_024)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPitchShifter(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPitchShifter(input, shift: 7, windowSize: 2_048, crossfade: 1_024)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testShift() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPitchShifter(input, shift: 7)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testWindowSize() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKPitchShifter(input, shift: 7, windowSize: 2_048)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
