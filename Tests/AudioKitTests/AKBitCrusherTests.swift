// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKBitCrusherTests: XCTestCase {

    func testBitDepth() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKBitCrusher(input, bitDepth: 12)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBypass() {
        let engine = AKEngine()
        let input = AKOscillator()
        let crush = AKBitCrusher(input, bitDepth: 12)
        crush.bypass()
        engine.output = crush
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKBitCrusher(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKBitCrusher(input, bitDepth: 12, sampleRate: 2_400)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSampleRate() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKBitCrusher(input, sampleRate: 2_400)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
