// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import AudioKit
import XCTest

class RhodesPianoKeyTests: XCTestCase {

    func testRhodesPiano() {
        let engine = AudioEngine()
        let rhodesPiano = RhodesPianoKey()
        rhodesPiano.trigger(note: 69)
        engine.output = rhodesPiano
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AudioEngine()
        let rhodesPiano = RhodesPianoKey()
        rhodesPiano.trigger(note: 69, velocity: 64)
        engine.output = rhodesPiano
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
#endif
