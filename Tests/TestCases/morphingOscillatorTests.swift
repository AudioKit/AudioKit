// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class MorphingOscillatorTests: AKTestCase {

    var oscillator = AKOperationGenerator { _ in return AKOperation.morphingOscillator() }

    override func setUp() {
        afterStart = { self.oscillator.start() }
        duration = 1.0
    }

    func testDefault() {
        output = oscillator
        AKTestMD5("d45f894aa1d536e63bffc536dc7f4edf")
    }

}
