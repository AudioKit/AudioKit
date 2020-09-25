// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class SawtoothTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let sawtooth = OperationGenerator { Operation.sawtooth() }
        engine.output = sawtooth
        sawtooth.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
