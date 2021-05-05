// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFoundation

// Commented out these tests due to intermittent failure on CI

//class AppleSamplerTests: XCTestCase {
//    let sampler = AppleSampler()
//    let engine = AudioEngine()
//
//    override func setUpWithError() throws {
//        let sampleURL = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")!
//        let audioFile = try AVAudioFile(forReading: sampleURL)
//        try sampler.loadAudioFile(audioFile)
//        engine.output = sampler
//    }
//
//    func testSamplePlayback() {
//        let audio = engine.startTest(totalDuration: 2.0)
//        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
//        audio.append(engine.render(duration: 2.0))
//        testMD5(audio)
//    }
//
//    func testStop() {
//        let audio = engine.startTest(totalDuration: 3.0)
//        sampler.play()
//        audio.append(engine.render(duration: 1.0))
//        sampler.stop()
//        audio.append(engine.render(duration: 1.0))
//        sampler.play()
//        audio.append(engine.render(duration: 1.0))
//        testMD5(audio)
//    }
//
//    func testAppleSamplerPolyphonicInheritance() {
//        func playMultiple(polyphonicNode: PolyphonicNode) {
//            polyphonicNode.play(noteNumber: 1, velocity: 127, channel: 1)
//            polyphonicNode.play(noteNumber: 2, velocity: 127, channel: 2)
//            polyphonicNode.play(noteNumber: 3, velocity: 127, channel: 3)
//        }
//        let audio = engine.startTest(totalDuration: 2.0)
//        playMultiple(polyphonicNode: sampler)
//        audio.append(engine.render(duration: 2.0))
//        testMD5(audio)
//    }
//
//    func testVolume() {
//        sampler.volume = 0.8
//        let audio = engine.startTest(totalDuration: 2.0)
//        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
//        audio.append(engine.render(duration: 2.0))
//        testMD5(audio)
//    }
//
//    func testPan() {
//        sampler.pan = 1.0
//        let audio = engine.startTest(totalDuration: 2.0)
//        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
//        audio.append(engine.render(duration: 2.0))
//        testMD5(audio)
//    }
//
//    func testAmplitude() {
//        sampler.amplitude = 12
//        let audio = engine.startTest(totalDuration: 2.0)
//        sampler.play(noteNumber: 50, velocity: 127, channel: 1)
//        audio.append(engine.render(duration: 2.0))
//        testMD5(audio)
//    }
//}
