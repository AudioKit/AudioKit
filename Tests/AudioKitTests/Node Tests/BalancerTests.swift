// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class BalancerTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        let comparator = Oscillator(waveform: Table(.triangle))
        engine.output = Balancer(input, comparator: comparator)
        input.start()
        comparator.start()
        let audio = engine.startTest(totalDuration: 1.0)
        comparator.$amplitude.ramp(to: 0, duration: 0.5)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
