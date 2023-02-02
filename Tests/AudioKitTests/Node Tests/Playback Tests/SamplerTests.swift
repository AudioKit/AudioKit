// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class SamplerTests: XCTestCase {
    func testSampler() {
        let engine = Engine()
        let sampler = Sampler()
        sampler.play(url: URL.testAudio)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testSamplerMIDINote() {
        let engine = Engine()
        let sampler = Sampler()
        sampler.assign(url: URL.testAudio, to: 60)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.playMIDINote(60)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testDynamicsProcessorWithSampler() {
        let engine = Engine()
        let buffer = try! AVAudioPCMBuffer(url: URL.testAudio)!
        let sampler = Sampler()
        sampler.play(buffer)
        engine.output = DynamicsProcessor(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
