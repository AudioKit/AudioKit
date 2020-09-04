// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKFlatFrequencyResponseReverbTests: XCTestCase {

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFlatFrequencyResponseReverb(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testLoopDuration() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1, loopDuration: 0.05)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testReverbDuration() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKFlatFrequencyResponseReverb(input, reverbDuration: 0.1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
