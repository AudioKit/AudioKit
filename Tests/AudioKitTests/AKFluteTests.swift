// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFluteTests: XCTestCase {

    func testFlute() {
        let engine = AKEngine()
        let flute = AKFlute()
        flute.trigger(note: 69)
        engine.output = flute

        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)

    }

    func testVelocity() {
        let engine = AKEngine()
        let flute = AKFlute()
        flute.trigger(note: 69, velocity: 64)
        engine.output = flute
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
