// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKCompressorTests: XCTestCase {

    func testAttackTime() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKCompressor(input, attackTime: 0.1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKCompressor(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHeadRoom() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKCompressor(input, headRoom: 0)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMasterGain() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKCompressor(input, masterGain: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKCompressor(input,
                                     threshold: -25,
                                     headRoom: 10,
                                     attackTime: 0.1,
                                     releaseTime: 0.1,
                                     masterGain: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    // Release time is not currently tested

    func testThreshold() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKCompressor(input, threshold: -25)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

}
