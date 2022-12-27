// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class MixerTests: XCTestCase {
    func testSplitConnection() {
        let engine = Engine()
        let sampler = Sampler()
        let mixer1 = Mixer(sampler)
        let mixer2 = Mixer()
        engine.output = Mixer(mixer1, mixer2)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: URL.testAudio)
        audio.append(engine.render(duration: 1.0))
        mixer2.addInput(sampler)
        mixer2.removeInput(sampler)
        mixer2.addInput(sampler)
        testMD5(audio)
    }

    func testWiringAfterEngineStart() {
        let engine = Engine()
        let engineMixer = Mixer()

        engine.output = engineMixer
        try? engine.start()

        let subtreeMixer = Mixer()
        engineMixer.addInput(subtreeMixer)

        let sampler = Sampler()
        subtreeMixer.addInput(sampler)

        sampler.play(url: URL.testAudio)

        // only for auditioning
        // wait(for: 2.0)
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

        let sampler = Sampler()

        let mixerA = Mixer(volume: 0.5, name: "mixerA")
        mixerA.addInput(sampler)
        engineMixer.addInput(mixerA)

        let mixerB = Mixer(sampler, name: "mixerB")
        mixerB.volume = 0.5
        engineMixer.addInput(mixerB)

        try? engine.start()

        if let mixerANode = mixerA.avAudioNode as? AVAudioMixerNode {
            XCTAssertEqual(mixerANode.outputVolume, mixerA.volume)
        }

        if let mixerBNode = mixerB.avAudioNode as? AVAudioMixerNode {
            XCTAssertEqual(mixerBNode.outputVolume, mixerA.volume)
        }

        engine.stop()
    }
}
