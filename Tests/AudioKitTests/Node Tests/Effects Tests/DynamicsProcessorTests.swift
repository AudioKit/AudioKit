// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

class DynamicsProcessorTests: AKTestCase {
    func testDefault() throws {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = DynamicsProcessor(sampler)
        sampler.play(url: .testAudio)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testPreset() throws {
        let engine = AudioEngine()
        let sampler = Sampler()
        let processor = DynamicsProcessor(sampler)
        processor.loadFactoryPreset(.fastAndSmooth)
        engine.output = processor
        sampler.play(url: .testAudio)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testAttackTime() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = DynamicsProcessor(sampler, attackTime: 0.1)
        sampler.play(url: .testAudio)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHeadRoom() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = DynamicsProcessor(sampler, headRoom: 0)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMasterGain() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = DynamicsProcessor(sampler, masterGain: 1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = DynamicsProcessor(sampler,
                                          threshold: -25,
                                          headRoom: 10,
                                          attackTime: 0.1,
                                          releaseTime: 0.1,
                                          masterGain: 1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    // Release time is not currently tested

    func testThreshold() {
        let engine = AudioEngine()
        let sampler = Sampler()
        engine.output = DynamicsProcessor(sampler, threshold: -25)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
