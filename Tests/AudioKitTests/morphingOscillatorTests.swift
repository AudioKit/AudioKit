// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class MorphingOscillatorTests: AKTestCase {

    var oscillator = AKOperationGenerator { AKOperation.morphingOscillator() }

    override func setUp() {
        afterStart = { self.oscillator.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = oscillator
        AKTest()
    }

}
