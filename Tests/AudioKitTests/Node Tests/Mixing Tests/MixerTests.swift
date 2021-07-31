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

    // for waiting in the background for realtime testing
    private func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }
}
