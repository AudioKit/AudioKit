// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class KorgLowPassFilterOperationTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { $0.korgLowPassFilter() }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = OperationEffect(input) { input in
            return input.korgLowPassFilter(cutoffFrequency: 2_000, resonance: 0.9, saturation: 0.5)
        }
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
