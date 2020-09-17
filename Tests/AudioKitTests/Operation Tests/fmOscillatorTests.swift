// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class FMOscillatorOperationTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let oscillator = OperationGenerator { Operation.fmOscillator() }
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testFMOscillatorOperation() {
        let engine = AudioEngine()
        let oscillator = OperationGenerator {
            let line = Operation.lineSegment(
                trigger: Operation.metronome(frequency: 0.1),
                start: 0.001,
                end: 5,
                duration: 1.0)
            return Operation.fmOscillator(
                baseFrequency: line * 1_000,
                carrierMultiplier: line,
                modulatingMultiplier: 5.1 - line,
                modulationIndex: line * 6,
                amplitude: line / 5)
        }
        engine.output = oscillator
        oscillator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
