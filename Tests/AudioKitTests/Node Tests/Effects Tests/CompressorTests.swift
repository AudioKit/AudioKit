// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFoundation

class CompressorTests: XCTestCase {
    func testAttackTime() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Compressor(sampler, attackTime: 0.1)
        sampler.play(url: URL.testAudio)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Compressor(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testHeadRoom() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Compressor(sampler, headRoom: 0)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testMasterGain() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Compressor(sampler, masterGain: 1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testParameters() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Compressor(sampler,
                                   threshold: -25,
                                   headRoom: 10,
                                   attackTime: 0.1,
                                   releaseTime: 0.1,
                                   masterGain: 1)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    // Release time is not currently tested

    func testThreshold() {
        let engine = Engine()
        let sampler = Sampler()
        engine.output = Compressor(sampler, threshold: -25)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
