// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class PhasorTests: AKTestCase {

    let phasor = AKOperationGenerator { AKOperation.phasor() }

    override func setUp() {
        super.setUp()
        afterStart = { self.phasor.start() }
        duration = 1.0
    }

    func testDefault() {
        engine.output = phasor
        AKTest()
    }

}
