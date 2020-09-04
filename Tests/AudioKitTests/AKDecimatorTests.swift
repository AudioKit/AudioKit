// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKDecimatorTests: XCTestCase {

    func testDecimation() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDecimator(input, decimation: 0.75)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDecimator(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMix() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDecimator(input, mix: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDecimator(input, decimation: 0.75, rounding: 0.5, mix: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testRounding() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKDecimator(input, rounding: 0.5)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
