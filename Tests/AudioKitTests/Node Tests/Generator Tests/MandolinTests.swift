// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
#if !os(tvOS)

import AudioKit
import XCTest

class MandolinStringTests: XCTestCase {

    func testMandolin() {
        let engine = AudioEngine()
        let mandolin = MandolinString()
        mandolin.trigger(note: 69)
        engine.output = mandolin
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

    }

    func testAmplitude() {
        let engine = AudioEngine()
        let mandolin = MandolinString()
        mandolin.trigger(note: 69, velocity: 64)
        engine.output = mandolin
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
#endif
