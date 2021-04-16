// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DynamicsProcessorTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let input = Oscillator(waveform: Table(.triangle))
        engine.output = DynamicsProcessor(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
// TODO: Figure out why this and Expander give different results on CI
//        testMD5(audio)
    }

}
