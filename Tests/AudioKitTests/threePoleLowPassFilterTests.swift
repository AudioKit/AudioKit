// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class ThreePoleLowPassFilterTests: AKTestCase {

    override func setUp() {
        super.setUp()
        duration = 1.0
    }

    func testParameterSweep() {
        engine.output = AKOperationEffect(input) { input in
            let ramp = AKOperation.lineSegment(
                trigger: AKOperation.metronome(),
                start: 1,
                end: 0,
                duration: duration)
            return input.threePoleLowPassFilter(distortion: ramp, cutoffFrequency: ramp * 8_000, resonance: ramp * 0.9)
        }
        AKTest()
    }

}
