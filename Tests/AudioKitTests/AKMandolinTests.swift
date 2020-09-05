// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKMandolinStringTests: XCTestCase {

    func testMandolin() {
        let engine = AKEngine()
        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69)
        engine.output = mandolin
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

    }

    func testAmplitude() {
        let engine = AKEngine()
        let mandolin = AKMandolinString()
        mandolin.trigger(note: 69, velocity: 64)
        engine.output = mandolin
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
