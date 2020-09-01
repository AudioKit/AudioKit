// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class SawtoothWaveTests: AKTestCase {

    let sawtooth = AKOperationGenerator { AKOperation.sawtoothWave() }

    override func setUp() {
        afterStart = { self.sawtooth.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = sawtooth
        AKTest()
    }

}
