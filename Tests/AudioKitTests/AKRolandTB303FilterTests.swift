// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKRolandTB303FilterTests: AKTestCase2 {

    func testCutoffFrequency() {
        output = AKRolandTB303Filter(input, cutoffFrequency: 400)
        AKTest()
    }

    func testDefault() {
        output = AKRolandTB303Filter(input)
        AKTest()
    }

    func testDistortion() {
        output = AKRolandTB303Filter(input, distortion: 1)
        AKTest()
    }

    func testParameters() {
        output = AKRolandTB303Filter(input,
                                     cutoffFrequency: 400,
                                     resonance: 1,
                                     distortion: 1,
                                     resonanceAsymmetry: 0.66)
        AKTest()
    }

    func testResonance() {
        output = AKRolandTB303Filter(input, resonance: 1)
        AKTest()
    }

    func testResonanceAsymmetry() {
        output = AKRolandTB303Filter(input, resonanceAsymmetry: 0.66)
        AKTest()
    }
}
