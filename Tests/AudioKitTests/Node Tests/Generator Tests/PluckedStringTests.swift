// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PluckedStringTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let pluck = PluckedString()
        pluck.trigger()
        engine.output = pluck
        let audio = engine.startTest(totalDuration: 3.0)
        audio.append(engine.render(duration: 1.0))
        pluck.trigger(frequency: 120)
        audio.append(engine.render(duration: 1.0))
        pluck.trigger(frequency: 130, amplitude: 0.5)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
