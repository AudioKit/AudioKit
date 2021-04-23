// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFoundation

class AppleSamplerTests: XCTestCase {
    func testSamplePlayback() {
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "Resources/drumloop", withExtension: "wav")!
        guard let audioFile = try? AVAudioFile(forReading: sampleURL) else {
            XCTFail("Failed to load drumloop sample")
            return
        }
        try? sampler.loadAudioFile(audioFile)

        let engine = AudioEngine()
        engine.output = sampler

        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testStop() {
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "Resources/drumloop", withExtension: "wav")!
        guard let audioFile = try? AVAudioFile(forReading: sampleURL) else {
            XCTFail("Failed to load drumloop sample")
            return
        }
        try? sampler.loadAudioFile(audioFile)

        let engine = AudioEngine()
        engine.output = sampler

        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
        // this immediately stops the sample
        sampler.stop(noteNumber: 50, channel: 1)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testAppleSamplerPolyphonicInheritance() {
        let sampler = AppleSampler()
        let sampleURL = Bundle.module.url(forResource: "Resources/drumloop", withExtension: "wav")!
        guard let audioFile = try? AVAudioFile(forReading: sampleURL) else {
            XCTFail("Failed to load drumloop sample")
            return
        }
        try? sampler.loadAudioFile(audioFile)

        let engine = AudioEngine()
        engine.output = sampler

        func playMultiple(polyphonicNode: PolyphonicNode) {
            polyphonicNode.play(noteNumber: 1, velocity: 127, channel: 1)
            polyphonicNode.play(noteNumber: 2, velocity: 127, channel: 2)
            polyphonicNode.play(noteNumber: 3, velocity: 127, channel: 3)
        }

        let audio = engine.startTest(totalDuration: 2.0)
        playMultiple(polyphonicNode: sampler)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }
}
