// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFAudio

class ReverbTests: XCTestCase {

    #if os(iOS)

    func testBypass() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        let effect = Reverb(input)
        effect.bypass()
        engine.output = effect
        let audio = engine.startTest(totalDuration: 1.0)
        input.start()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testNotStartedWhenBypassed() {
        let effect = Reverb(AudioPlayer())
        effect.isStarted = true
        effect.bypass()
        XCTAssertFalse(effect.isStarted)
    }

    func testNotStartedWhenBypassedAsNode() {
        // Node has its own extension of bypass
        // bypass() needs to be a part of protocol
        // for this to work properly
        let effect = Reverb(AudioPlayer())
        effect.isStarted = true
        (effect as Node).bypass()
        XCTAssertFalse(effect.isStarted)
    }

    func testStartedAfterStart() {
        let effect = Reverb(AudioPlayer())
        effect.isStarted = false
        effect.start()
        XCTAssertTrue(effect.isStarted)
    }

    func testCathedral() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        let effect = Reverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.cathedral)
        let audio = engine.startTest(totalDuration: 1.0)
        input.start()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testDefault() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        engine.output = Reverb(input)
        let audio = engine.startTest(totalDuration: 1.0)
        input.start()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSmallRoom() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let input = AudioPlayer(url: url)!
        let effect = Reverb(input)
        engine.output = effect
        effect.loadFactoryPreset(.smallRoom)
        let audio = engine.startTest(totalDuration: 1.0)
        input.start()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    #endif

}
