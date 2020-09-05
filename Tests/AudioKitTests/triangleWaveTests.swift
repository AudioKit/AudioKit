// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TriangleWaveTests: XCTestCase {

    func testParameterSweep() {
        let engine = AKEngine()
        let triangle = AKOperationGenerator {
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: 1.0)
            return AKOperation.triangleWave(frequency: ramp * 2_000, amplitude: ramp)
        }
        engine.output = triangle
        triangle.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
