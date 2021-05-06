// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import CAudioKit

class SynthTests: XCTestCase {

    func testChord() {
        DebugDSPSetActive(true)
        let engine = AudioEngine()
        let synth = Synth()
        engine.output = synth
        let audio = engine.startTest(totalDuration: 1.0)
        synth.play(noteNumber: 64, velocity: 120)
        synth.play(noteNumber: 67, velocity: 120)
        synth.play(noteNumber: 71, velocity: 120)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
