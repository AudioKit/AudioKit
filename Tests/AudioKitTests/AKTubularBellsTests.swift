// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKTubularBellsTests: XCTestCase {

    func testTubularBells() {
        let engine = AKEngine()
        let bells = AKTubularBells()
        bells.trigger(note: 69)
        engine.output = bells
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAmplitude() {
        let engine = AKEngine()
        let bells = AKTubularBells()
        bells.trigger(note: 69, velocity: 64)
        engine.output = bells
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
