// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDCBlockTests: AKTestCase {

    func testActuallyProcessing() {
        let input = AKOscillator(waveform: AKTable(.square))
        output = input
        AKTestMD5Not("cdca0c19d803bbf2cce357df5fca3013")
    }

    func testDefault() {
        output = AKDCBlock(input)
        AKTestMD5("cdca0c19d803bbf2cce357df5fca3013")
    }

}
