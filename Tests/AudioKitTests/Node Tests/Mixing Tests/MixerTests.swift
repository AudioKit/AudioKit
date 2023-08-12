// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class MixerTests: AKTestCase {
    func testSplitConnection() {
        let engine = AudioEngine()
        let sampler = Sampler()
        let mixer1 = Mixer(sampler)
        let mixer2 = Mixer()
        engine.output = Mixer(mixer1, mixer2)
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: .testAudio)
        audio.append(engine.render(duration: 1.0))
        mixer2.addInput(sampler)
        mixer2.removeInput(sampler)
        mixer2.addInput(sampler)
        testMD5(audio)
    }

    func testWiringAfterEngineStart() {
        let engine = AudioEngine()
        let engineMixer = Mixer()

        engine.output = engineMixer
        try? engine.start()

        let subtreeMixer = Mixer()
        engineMixer.addInput(subtreeMixer)

        let sampler = Sampler()
        subtreeMixer.addInput(sampler)

        sampler.play(url: .testAudio)

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
}
