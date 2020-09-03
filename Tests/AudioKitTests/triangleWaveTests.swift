// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class TriangleWaveTests: AKTestCase {

    var triangle = AKOperationGenerator { AKOperation.triangleWave() }

    override func setUp() {
        afterStart = { self.triangle.start() }
        duration = 1.0
    }

    func testParameterSweep() {
        triangle = AKOperationGenerator {
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: duration)
            return AKOperation.triangleWave(frequency: ramp * 2_000, amplitude: ramp)
        }
        engine.output = triangle
        AKTest()
    }

}
