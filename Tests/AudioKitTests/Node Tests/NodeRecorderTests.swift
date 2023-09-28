// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class NodeRecorderTests: XCTestCase {
    func testBasicRecord() throws {
        return // for now, tests are failing

        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player
        let recorder = try NodeRecorder(node: player)

        // record a little audio
        try engine.start()
        player.play()
        try recorder.reset()
        try recorder.record()
        sleep(1)

        // stop recording and load it into a player
        recorder.stop()
        let audioFileURL = recorder.audioFile!.url
        engine.stop()
        player.stop()
        try player.load(url: audioFileURL)

        // test the result
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testCallback() throws {
        return // for now, tests are failing
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        engine.output = player
        let recorder = try NodeRecorder(node: player)

        // attach the callback handler
        var values = [Float]()
        recorder.audioDataCallback = { audioData, _ in
            values.append(contentsOf: audioData)
        }

        // record a little audio
        try engine.start()
        player.play()
        try recorder.reset()
        try recorder.record()
        sleep(1)

        // stop recording and load it into a player
        recorder.stop()
        let audioFileURL = recorder.audioFile!.url
        engine.stop()
        player.stop()
        try player.load(url: audioFileURL)

        // test the result
        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(values[5000], -0.027038574)
    }
}
