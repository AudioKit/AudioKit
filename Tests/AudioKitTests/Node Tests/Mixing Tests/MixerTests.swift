// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

class MixerTests: XCTestCase {
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

    func testDoesntCrashWhenAddingSamplersInSubmix() throws {
        let engine = AudioEngine()
        engine.output = createMix()
        try! engine.start()

        wait(for: 0.1)
        engine.output = createMix()

        wait(for: 0.1)
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

private func createSampler() -> AppleSampler {
    let sampler = AppleSampler()
    let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
    let audioFile = try! AVAudioFile(forReading: sampleURL)
    try! sampler.loadAudioFile(audioFile)
    return sampler
}

private func createMix() -> Mixer {
    let mixer = Mixer()
    DispatchQueue.main.async {
        mixer.addInput(createSubMix())
        mixer.addInput(createSubMix())
    }
    return mixer
}

private func createSubMix() -> Mixer {
    let mixer = Mixer() // Mixer([DummyNode()]) Initializing Mixer with DummyNode fixes the problem
    DispatchQueue.main.async { mixer.addInput(createSampler()) }
    return mixer
}

private class DummyNode: Node {
    private let dummy = AVAudioPlayerNode()
    var connections: [Node] = []
    var avAudioNode: AVAudioNode { dummy }
}
