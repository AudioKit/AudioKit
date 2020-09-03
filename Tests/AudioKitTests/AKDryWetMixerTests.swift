// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

class AKDryWetMixerTests: AKTestCase {
    let input1 = AKOscillator()
    let input2 = AKOscillator(frequency: 1280)

    func testDefault() {

        let mixer = AKDryWetMixer(dry: input1, wet: input2)
        engine.output = mixer

        input1.start()
        input2.start()
        AKTest()
    }

    func testBalance0() {

        let mixer = AKDryWetMixer(dry: input1, wet: input2, balance: 0)
        engine.output = mixer

        input1.start()
        input2.start()
        AKTest()
    }

    func testBalance1() {

        let mixer = AKDryWetMixer(dry: input1, wet: input2, balance: 1)
        engine.output = mixer

        input1.start()
        input2.start()
        AKTest()
    }

}
