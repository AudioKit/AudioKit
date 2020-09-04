// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKResonantFilterTests: XCTestCase {

    func testBandwidth() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKResonantFilter(input, bandwidth: 500)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKResonantFilter(input)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFrequency() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKResonantFilter(input, frequency: 1_000)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKResonantFilter(input, frequency: 1_000, bandwidth: 500)
        input.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
