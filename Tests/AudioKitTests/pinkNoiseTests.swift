// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PinkNoiseTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let noise = AKOperationGenerator { AKOperation.pinkNoise() }
        engine.output = noise
        noise.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AKEngine()
        let noise = AKOperationGenerator {
            return AKOperation.pinkNoise(amplitude: 0.456)
        }
        engine.output = noise
        noise.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameterSweep() {
        let engine = AKEngine()
        let noise = AKOperationGenerator {
            let line = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 0,
                end: 1,
                duration: 1.0)
            return AKOperation.pinkNoise(amplitude: line)
        }
        engine.output = noise
        noise.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
