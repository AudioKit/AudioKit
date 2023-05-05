// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFAudio
import XCTest

class ReverbTests: AKTestCase {
    func testBypass() {
        let engine = Engine()
        let input = Sampler()
        let effect = Reverb(input)
        effect.bypassed = true
        engine.output = effect
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testCathedral() {
        let engine = Engine()
        let input = Sampler()
        let effect = Reverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.cathedral)
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = Engine()
        let input = Sampler()
        engine.output = Reverb(input)
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSmallRoom() {
        let engine = Engine()
        let input = Sampler()
        let effect = Reverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.smallRoom)
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
