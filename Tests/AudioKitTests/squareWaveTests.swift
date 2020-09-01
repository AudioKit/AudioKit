// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class SquareWaveTests: AKTestCase {

    let square = AKOperationGenerator { AKOperation.squareWave() }

    override func setUp() {
        afterStart = { self.square.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = square
        AKTest()
    }

}
