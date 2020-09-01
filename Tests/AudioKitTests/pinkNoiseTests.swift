// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class PinkNoiseTests: AKTestCase {

    var noise = AKOperationGenerator { AKOperation.pinkNoise() }

    override func setUp() {
        afterStart = { self.noise.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = noise
        AKTest()
    }

    func testAmplitude() {
        noise = AKOperationGenerator {
            return AKOperation.pinkNoise(amplitude: 0.456)
        }
        engine.output = noise
        AKTest()
    }

    func testParameterSweep() {
        noise = AKOperationGenerator {
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: duration)
            return AKOperation.pinkNoise(amplitude: line)
        }
        engine.output = noise
        AKTest()
    }

}
