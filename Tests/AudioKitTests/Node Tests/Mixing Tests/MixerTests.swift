// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class MixerTests: XCTestCase {
    override func setUp() {
        Settings.sampleRate = 44100
    }

    func testSplitConnection() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let mixer1 = Mixer(player)
        let mixer2 = Mixer()
        engine.output = Mixer(mixer1, mixer2)
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        mixer2.addInput(player)
        mixer2.removeInput(player)
        mixer2.addInput(player)
        testMD5(audio)
    }
}

extension MixerTests {

    // Tests workaround for:
    // http://openradar.appspot.com/radar?id=5588189343383552
    func testWiringAfterEngineStart() {
        let engine = AudioEngine()
        let engineMixer = Mixer()

        engine.output = engineMixer
        try? engine.start()

        let subtreeMixer = Mixer()
        engineMixer.addInput(subtreeMixer)

        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        subtreeMixer.addInput(player)

        print(engine.connectionTreeDescription)
        player.play()

        // only for auditioning
        // wait(for: player.duration)
        engine.stop()
    }

    @available(iOS 16.0, *)
    // This is the same bug as the test above.
    // However, there is no easy way to detect that engine is paused.
    // There is currently no workaround for this in AudioKit.
    // Apps will need to manually insert empty nodes
    // http://openradar.appspot.com/radar?id=5588189343383552
    func testWiringAfterEngineStartedAndPaused() async throws {
        try XCTSkipIf(true, "Enable if we find a way to workaround this")
        let engine = AudioEngine()
        let engineMixer = Mixer()

        engine.output = engineMixer
        try engine.start()
        try await Task.sleep(for: .milliseconds(1000))
        engine.pause()

        let subtreeMixer = Mixer()
        engineMixer.addInput(subtreeMixer)

        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        subtreeMixer.addInput(player)

        try? engine.start()
        print(engine.connectionTreeDescription)
        player.play()

        // only for auditioning
        // wait(for: player.duration)
        engine.stop()
    }
    // for waiting in the background for realtime testing
    private func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }

    func testMixerVolume() {
        let engine = AudioEngine()
        let engineMixer = Mixer()
        engine.output = engineMixer

        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!

        let mixerA = Mixer(volume: 0.5, name: "mixerA")
        mixerA.addInput(player)
        engineMixer.addInput(mixerA)

        let mixerB = Mixer(player, name: "mixerB")
        mixerB.volume = 0.3
        engineMixer.addInput(mixerB)

        try? engine.start()

        let mixerANode = mixerA.avAudioNode as! AVAudioMixerNode
        XCTAssertEqual(mixerANode.outputVolume, mixerA.volume)

        let mixerBNode = mixerB.avAudioNode as! AVAudioMixerNode
        XCTAssertEqual(mixerBNode.outputVolume, mixerB.volume)

        engine.stop()
    }

    func testMixerVolumeWhenAddingIncrementally() {
        let engine = AudioEngine()
        let engineMixer = Mixer()
        engine.output = engineMixer

        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!

        let mixerA = Mixer(volume: 0.5, name: "mixerA")
        mixerA.addInput(player, strategy: .incremental)
        engineMixer.addInput(mixerA)

        let mixerB = Mixer(player, name: "mixerB")
        mixerB.volume = 0.3
        engineMixer.addInput(mixerB, strategy: .incremental)

        try? engine.start()

        let mixerANode = mixerA.avAudioNode as! AVAudioMixerNode
        XCTAssertEqual(mixerANode.outputVolume, mixerA.volume)

        let mixerBNode = mixerB.avAudioNode as! AVAudioMixerNode
        XCTAssertEqual(mixerBNode.outputVolume, mixerB.volume)

        engine.stop()
    }
}
