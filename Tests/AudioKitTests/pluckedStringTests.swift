// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class PluckedStringTests: AKTestCase {

    let pluckedString = AKOperationGenerator {
        return AKOperation.pluckedString(trigger: AKOperation.metronome())
    }

    override func setUp() {
        afterStart = { self.pluckedString.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = pluckedString
        AKTest()
    }

}
