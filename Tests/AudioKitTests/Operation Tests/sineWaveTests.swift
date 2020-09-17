// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class SineWaveTests: XCTestCase {

    func testDefault() {
        let engine = AudioEngine()
        let sine = OperationGenerator { Operation.sineWave() }
        engine.output = sine
        sine.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
