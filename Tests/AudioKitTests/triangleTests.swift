// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class TriangleTests: AKTestCase {

    var triangle = AKOperationGenerator { AKOperation.triangle() }

    override func setUp() {
        afterStart = { self.triangle.start() }
        duration = 1.0
    }

    func testParameterSweep() {
        triangle = AKOperationGenerator { _ in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: duration)
            return AKOperation.triangle(frequency: ramp * 2_000, amplitude: ramp, phase: ramp)
        }
        output = triangle
        AKTest()
    }

}
