// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PhasorTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let phasor = OperationGenerator { Operation.phasor() }
        engine.output = phasor
        phasor.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
