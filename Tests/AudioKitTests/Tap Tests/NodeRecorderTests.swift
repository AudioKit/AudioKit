// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class NodeRecorderTests: AKTestCase {
    func testBasicRecord() async throws {

        let engine = Engine()
        let sampler = Sampler()
        engine.output = sampler
        let recorder = try await Recorder(node: sampler)

        // record a little audio
        try engine.start()
        sampler.play(url: .testAudio)
        try await recorder.reset()
        try await recorder.record()
        sleep(1)

        // stop recording and load it into a player
        await recorder.stop()
        let audioFileURL = await recorder.audioFile!.url
        engine.stop()
        sampler.stop()

        // test the result
        let audio = engine.startTest(totalDuration: 1.0)
        sampler.play(url: audioFileURL)
        audio.append(engine.render(duration: 1.0))
        audio.audition()
        //testMD5(audio)
    }
//
//    func testCallback() throws {
//        return // for now, tests are failing
//        let engine = Engine()
//        let sampler = Sampler()
//        engine.output = sampler
//        let recorder = try NodeRecorder(node: sampler)
//
//        // attach the callback handler
//        var values = [Float]()
//        recorder.audioDataCallback = { audioData, _ in
//            values.append(contentsOf: audioData)
//        }
//
//        // record a little audio
//        try engine.start()
//        sampler.play(url: .testAudio)
//        try recorder.reset()
//        try recorder.record()
//        sleep(1)
//
//        // stop recording and load it into a player
//        recorder.stop()
//        let audioFileURL = recorder.audioFile!.url
//        engine.stop()
//        sampler.stop()
//
//        // test the result
//        let audio = engine.startTest(totalDuration: 1.0)
//        sampler.play(url: audioFileURL)
//        audio.append(engine.render(duration: 1.0))
//        XCTAssertEqual(values[5000], -0.027038574)
//    }
}
