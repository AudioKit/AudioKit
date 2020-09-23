// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class TapNodeTests: XCTestCase {

    func testPassesAudioThrough() {
        let engine = AudioEngine()
        let input = Oscillator()
        let tap = TapNode(input)
        engine.output = tap
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
