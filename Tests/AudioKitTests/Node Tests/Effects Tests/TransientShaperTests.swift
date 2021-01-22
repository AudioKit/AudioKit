// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TransientShaperTests: XCTestCase {

    func testAttackAmount() {
        let engine = AudioEngine()
        let input = Oscillator(amplitude: 2.0)
        engine.output = TransientShaper(input, attackAmount: 3.0, releaseAmount: -40.0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(amplitude: 2.0)
        engine.output = TransientShaper(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator(amplitude: 2.0)
        engine.output = TransientShaper(input,
                                        inputAmount: -1.0,
                                        attackAmount: 1.5,
                                        releaseAmount: -40.0,
                                        outputAmount: -3.0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testInputAmount() {
        let engine = AudioEngine()
        let input = Oscillator(amplitude: 2.0)
        engine.output = TransientShaper(input, inputAmount: -5.0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testReleaseAmount() {
        let engine = AudioEngine()
        let input = Oscillator(amplitude: 2.0)
        engine.output = TransientShaper(input, releaseAmount: 5.0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testOutputAmount() {
        let engine = AudioEngine()
        let input = Oscillator(amplitude: 2.0)
        engine.output = TransientShaper(input, outputAmount: -10.0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
