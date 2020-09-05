// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFormantFilterTests: XCTestCase {

    func testAttack() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFormantFilter(input, attackDuration: 0.023_4)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testCenterFrequency() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFormantFilter(input, centerFrequency: 500)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecay() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFormantFilter(input, decayDuration: 0.023_4)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFormantFilter(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
