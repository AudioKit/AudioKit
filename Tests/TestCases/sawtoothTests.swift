// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class SawtoothTests: AKTestCase {

    let sawtooth = AKOperationGenerator { _ in return AKOperation.sawtooth() }

    override func setUp() {
        afterStart = { self.sawtooth.start() }
        duration = 1.0
    }

    func testDefault() {
        output = sawtooth
        AKTestMD5("582e76f338bafc30a1a0954313891a5e")
    }

}
