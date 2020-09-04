// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class SquareWaveTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let square = AKOperationGenerator { AKOperation.squareWave() }
        engine.output = square
        square.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
