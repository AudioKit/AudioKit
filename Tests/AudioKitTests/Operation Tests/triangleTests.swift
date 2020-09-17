// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TriangleTests: XCTestCase {

    func testParameterSweep() {
        let engine = AudioEngine()
        let triangle = OperationGenerator {
            let ramp = Operation.lineSegment(
                trigger: Operation.metronome(),
                start: 1.0,
                end: 0.0,
                duration: 1.0)
            return Operation.triangle(frequency: ramp * 2_000, amplitude: ramp, phase: ramp)
        }
        engine.output = triangle
        triangle.play()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
