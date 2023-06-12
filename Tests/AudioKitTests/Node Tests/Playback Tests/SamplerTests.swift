// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class SamplerTests: AKTestCase {
    func testSampler() {
        let engine = AudioEngine()
        let sampler = Sampler()
        sampler.play(url: .testAudio)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testPlayMIDINote() {
        let engine = AudioEngine()
        let sampler = Sampler()
        sampler.assign(url: .testAudio, to: 60)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 60)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testStopMIDINote() {
        let engine = AudioEngine()
        let sampler = Sampler()
        sampler.assign(url: .testAudio, to: 60)
        sampler.assign(url: .testAudio, to: 61)
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 60)
        sampler.stop(noteNumber: 61) // Should not stop note 60
        audio.append(engine.render(duration: 1.0))
        sampler.stop(noteNumber: 60)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }


    func testDynamicsProcessorWithSampler() {
        let engine = AudioEngine()
        let buffer = try! AVAudioPCMBuffer(url: .testAudio)!
        let sampler = Sampler()
        sampler.play(buffer)
        engine.output = DynamicsProcessor(sampler)
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
}
