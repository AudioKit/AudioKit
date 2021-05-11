// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DripTests: XCTestCase {

    func testDampingFactor() {
        let engine = AudioEngine()
        let drip = Drip(dampingFactor: 1.9)
        engine.output = drip
        let audio = engine.startTest(totalDuration: 2.0)
        drip.trigger()
        audio.append(engine.render(duration: 1.0))
        drip.trigger()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AudioEngine()
        let drip = Drip()
        engine.output = drip
        let audio = engine.startTest(totalDuration: 2.0)
        drip.trigger()
        audio.append(engine.render(duration: 1.0))
        drip.trigger()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    /* Producing different results on M1 chip
    func testIntensity() {
        let engine = AudioEngine()
        let drip = Drip(intensity: 0.1)
        drip.start()
        engine.output = drip
        let audio = engine.startTest(totalDuration: 1.0)
        drip.trigger()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    */
}
