// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKRolandTB303FilterTests: AKTestCase {

    func testCutoffFrequency() {
        engine.output = AKRolandTB303Filter(input, cutoffFrequency: 400)
        AKTest()
    }

    func testDefault() {
        engine.output = AKRolandTB303Filter(input)
        AKTest()
    }

    func testDistortion() {
        engine.output = AKRolandTB303Filter(input, distortion: 1)
        AKTest()
    }

    func testParameters() {
        engine.output = AKRolandTB303Filter(input,
                                     cutoffFrequency: 400,
                                     resonance: 1,
                                     distortion: 1,
                                     resonanceAsymmetry: 0.66)
        AKTest()
    }

    func testResonance() {
        engine.output = AKRolandTB303Filter(input, resonance: 1)
        AKTest()
    }

    func testResonanceAsymmetry() {
        engine.output = AKRolandTB303Filter(input, resonanceAsymmetry: 0.66)
        AKTest()
    }
}
