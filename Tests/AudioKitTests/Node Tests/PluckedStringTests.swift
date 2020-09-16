// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKPluckedStringTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let pluck = AKPluckedString()
        pluck.start()
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
