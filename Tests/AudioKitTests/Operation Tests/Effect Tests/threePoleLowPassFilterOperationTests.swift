// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class ThreePoleLowPassFilterOperationTests: XCTestCase {

    func testParameterSweep() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { input in
            let ramp = Operation.lineSegment(
                trigger: Operation.metronome(),
                start: 1,
                end: 0,
                duration: 1.0)
            return input.threePoleLowPassFilter(distortion: ramp, cutoffFrequency: ramp * 8_000, resonance: ramp * 0.9)
        }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
