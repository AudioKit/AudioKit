// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

// The drum synths utilize "sine" which computes differently on M1 Macs, so this not testable in CI right now.


//class DrumSynthTests: XCTestCase {
//    func testSynthKick() {
//        let engine = AudioEngine()
//        let synthKick = SynthKick()
//        engine.output = synthKick
//
//        let audio = engine.startTest(totalDuration: 2.0)
//        synthKick.play(noteNumber: 64, velocity: 127)
//        audio.append(engine.render(duration: 1.0))
//        synthKick.play(noteNumber: 48, velocity: 32)
//        audio.append(engine.render(duration: 1.0))
//        testMD5(audio)
//    }
//
//    func testSynthSnare() {
//        let engine = AudioEngine()
//        let synthSnare = SynthSnare()
//        engine.output = synthSnare
//
//        let audio = engine.startTest(totalDuration: 2.0)
//        synthSnare.play(noteNumber: 64, velocity: 127)
//        audio.append(engine.render(duration: 1.0))
//        synthSnare.play(noteNumber: 48, velocity: 32)
//        audio.append(engine.render(duration: 1.0))
//        testMD5(audio)
//    }
//}
