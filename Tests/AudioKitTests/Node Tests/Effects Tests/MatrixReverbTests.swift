// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFAudio
import XCTest

#if os(macOS)

class MatrixReverbTests: XCTestCase {
    func testBypass() {
        let engine = Engine()
        let input = Sampler()
        let effect = MatrixReverb(input)
        effect.bypass()
        engine.output = effect
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNotStartedWhenBypassed() {
        let effect = MatrixReverb(Sampler())
        effect.bypass()
        XCTAssertFalse(effect.isStarted)
    }

    func testNotStartedWhenBypassedAsNode() {
        // Node has its own extension of bypass
        // bypass() needs to be a part of protocol
        // for this to work properly
        let effect = MatrixReverb(Sampler())
        (effect as Node).bypass()
        XCTAssertFalse(effect.isStarted)
    }

    func testStartedAfterStart() {
        let effect = MatrixReverb(Sampler())
        XCTAssertTrue(effect.isStarted)
    }

    func testCathedral() {
        let engine = Engine()
        let input = Sampler()
        let effect = MatrixReverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.cathedral)
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = Engine()
        let input = Sampler()
        engine.output = MatrixReverb(input)
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSmallRoom() {
        let engine = Engine()
        let input = Sampler()
        let effect = MatrixReverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.smallRoom)
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSmallLargeMix() {
        let engine = Engine()
        let input = Sampler()
        let effect = MatrixReverb(input)
        effect.smallLargeMix = 51
        engine.output = effect
        let audio = engine.startTest(totalDuration: 1.0)
        input.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}

#endif
