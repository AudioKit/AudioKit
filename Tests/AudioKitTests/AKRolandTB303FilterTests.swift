// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class AKRolandTB303FilterTests: XCTestCase {

    func testCutoffFrequency() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKRolandTB303Filter(input, cutoffFrequency: 400)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKRolandTB303Filter(input)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDistortion() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKRolandTB303Filter(input, distortion: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKRolandTB303Filter(input,
                                     cutoffFrequency: 400,
                                     resonance: 1,
                                     distortion: 1,
                                     resonanceAsymmetry: 0.66)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testResonance() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKRolandTB303Filter(input, resonance: 1)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testResonanceAsymmetry() {
        let engine = AKEngine()
        let input = AKOscillator()
        engine.output = AKRolandTB303Filter(input, resonanceAsymmetry: 0.66)
        input.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
