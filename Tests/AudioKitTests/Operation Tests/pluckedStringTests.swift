// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PluckedStringOperationTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let pluckedString = OperationGenerator {_ in
            return Operation.pluckedString(trigger: Operation.metronome())
        }
        engine.output = pluckedString
        pluckedString.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
