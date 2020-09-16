// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PluckedStringTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let pluckedString = AKOperationGenerator {_ in
            return AKOperation.pluckedString(trigger: AKOperation.metronome())
        }
        engine.output = pluckedString
        pluckedString.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
