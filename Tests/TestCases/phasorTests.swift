// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class PhasorTests: AKTestCase {

    let phasor = AKOperationGenerator { _ in return AKOperation.phasor() }

    override func setUp() {
        super.setUp()
        afterStart = { self.phasor.start() }
        duration = 1.0
    }

    func testDefault() {
        output = phasor
        AKTestMD5("3158517a6a14167e736cf7038a828dc8")
    }

}
