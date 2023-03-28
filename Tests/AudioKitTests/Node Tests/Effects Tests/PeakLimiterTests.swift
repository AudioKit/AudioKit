// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class PeakLimiterTests: XCTestCase {
    func testAttackTime() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = PeakLimiter(sampler, attackTime: 0.02)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecayTime() throws {
        let engine = Engine()
        let sampler = Sampler()
        let mixer = Mixer(sampler)
        mixer.volume = 5 // Had to be loud to allow for decay time to affected the sound
        engine.output = PeakLimiter(mixer, decayTime: 0.02)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDecayTime2() throws {
        let engine = Engine()
        let sampler = Sampler()
        let mixer = Mixer(sampler)
        mixer.volume = 5 // Had to be loud to allow for decay time to affected the sound
        engine.output = PeakLimiter(mixer, decayTime: 0.03)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = PeakLimiter(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = PeakLimiter(sampler, attackTime: 0.02, decayTime: 0.03, preGain: 1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPreGain() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = PeakLimiter(sampler, preGain: 1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPreGainChangingAfterEngineStarted() throws {
        let engine = Engine()
        let sampler = Sampler()
        let effect = PeakLimiter(sampler, attackTime: 0.02, decayTime: 0.03, preGain: -20)
        engine.output = effect
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        sampler.stop()
        sampler.play(url: .testAudio)
        effect.preGain = 40
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
