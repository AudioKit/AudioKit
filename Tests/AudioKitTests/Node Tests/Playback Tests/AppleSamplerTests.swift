// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

// Commented these out if still fail CI

class AppleSamplerTests: AKTestCase {

    func testSamplePlayback() throws {
        let sampler = AppleSampler()
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try AVAudioFile(forReading: sampleURL)
        try sampler.loadAudioFile(audioFile)
        engine.output = sampler

        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testStop() throws {
        let sampler = AppleSampler()
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try AVAudioFile(forReading: sampleURL)
        try sampler.loadAudioFile(audioFile)
        engine.output = sampler

        let audio = engine.startTest(totalDuration: 3.0)
        sampler.play()
        audio.append(engine.render(duration: 1.0))
        sampler.stop()
        audio.append(engine.render(duration: 1.0))
        sampler.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testVolume() throws {
        let sampler = AppleSampler()
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try AVAudioFile(forReading: sampleURL)
        try sampler.loadAudioFile(audioFile)
        engine.output = sampler

        sampler.volume = 0.8
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testPan() throws {
        let sampler = AppleSampler()
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try AVAudioFile(forReading: sampleURL)
        try sampler.loadAudioFile(audioFile)
        engine.output = sampler

        sampler.pan = 1.0
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    func testAmplitude() throws {
        let sampler = AppleSampler()
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/sinechirp", withExtension: "wav")!
        let audioFile = try AVAudioFile(forReading: sampleURL)
        try sampler.loadAudioFile(audioFile)
        engine.output = sampler

        sampler.amplitude = 12
        let audio = engine.startTest(totalDuration: 2.0)
        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
        audio.append(engine.render(duration: 2.0))
        testMD5(audio)
    }

    // Repro case.
    func testLoadEXS24_bug() throws {
        throw XCTSkip("Repro case")
        let engine = AVAudioEngine()
        let samplerUnit = AVAudioUnitSampler()
        engine.attach(samplerUnit)
        let exsURL = Bundle.module.url(forResource: "TestResources/Sampler Instruments/sawPiano1", withExtension: "exs")!
        try samplerUnit.loadInstrument(at: exsURL)
    }
}
