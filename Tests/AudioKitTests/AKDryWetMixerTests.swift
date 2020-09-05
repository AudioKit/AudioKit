// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKDryWetMixerTests: XCTestCase {
    let input1 = AKOscillator()
    let input2 = AKOscillator(frequency: 1280)

    func testDefault() {
        let engine = AKEngine()
        let mixer = AKDryWetMixer(dry: input1, wet: input2)
        engine.output = mixer

        input1.start()
        input2.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBalance0() {
        let engine = AKEngine()
        let mixer = AKDryWetMixer(dry: input1, wet: input2, balance: 0)
        engine.output = mixer

        input1.start()
        input2.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBalance1() {
        let engine = AKEngine()
        let mixer = AKDryWetMixer(dry: input1, wet: input2, balance: 1)
        engine.output = mixer

        input1.start()
        input2.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
