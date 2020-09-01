// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class FMOscillatorTests: AKTestCase {

    var oscillator = AKOperationGenerator { AKOperation.fmOscillator() }

    override func setUp() {
        afterStart = { self.oscillator.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = oscillator
        AKTest()
    }

    func testFMOscillatorOperation() {
        oscillator = AKOperationGenerator {
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(frequency: 0.1),
                start: 0.001,
                end: 5,
                duration: duration)
            return AKOperation.fmOscillator(
                baseFrequency: line * 1_000,
                carrierMultiplier: line,
                modulatingMultiplier: 5.1 - line,
                modulationIndex: line * 6,
                amplitude: line / 5)
        }
        engine.output = oscillator
        AKTest()
    }

}
