// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class NodeRecorderTests: XCTestCase {
    func testBasicRecord() throws {
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
        //testMD5(audio)
    }

    func testCallback() throws {
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
//        XCTAssertEqual(values[5000], -0.027038574)
    }

    /// Reproduces GitHub #2947: after multiple pause/resume cycles, the recorded
    /// duration drifts away from the expected elapsed play time.
    ///
    /// The NodeRecorder's tap block continuously fires even while paused.
    /// At each pause/resume boundary, a buffer that is already being processed may
    /// still get written, adding extra audio. Over multiple cycles this accumulates.
    func testPauseResumeDrift() throws {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        player.isLooping = true
        engine.output = player
        let recorder = try NodeRecorder(node: player)

        try engine.start()
        player.play()
        try recorder.reset()
        try recorder.record()

        let playInterval: UInt32 = 300_000  // 0.3s in microseconds
        let pauseInterval: UInt32 = 300_000 // 0.3s in microseconds
        let cycles = 10

        var totalPlayTime: TimeInterval = 0

        // Run multiple pause/resume cycles, tracking actual play time
        for _ in 0 ..< cycles {
            let playStart = CFAbsoluteTimeGetCurrent()
            usleep(playInterval)
            let playEnd = CFAbsoluteTimeGetCurrent()
            totalPlayTime += playEnd - playStart

            player.pause()
            recorder.pause()
            usleep(pauseInterval)
            player.play()
            recorder.resume()
        }
        // One final play segment
        let finalStart = CFAbsoluteTimeGetCurrent()
        usleep(playInterval)
        let finalEnd = CFAbsoluteTimeGetCurrent()
        totalPlayTime += finalEnd - finalStart

        recorder.stop()
        player.stop()
        engine.stop()

        let recordedDuration = recorder.audioFile?.duration ?? 0

        // The recorded duration should be close to the total time we spent in "playing" state.
        // Each pause/resume boundary can leak up to one buffer (~10ms at 512 samples/48kHz).
        // Over 10 cycles that's up to ~200ms of drift.
        let drift = abs(recordedDuration - totalPlayTime)
        let perCycleDrift = drift / Double(cycles)

        // Allow up to 15ms per cycle (generous for buffer boundary effects).
        // If the drift is significantly larger, it indicates a synchronization bug.
        XCTAssertLessThan(perCycleDrift, 0.015,
                          "Per-cycle drift of \(perCycleDrift * 1000)ms " +
                          "(total: \(drift * 1000)ms over \(cycles) cycles). " +
                          "Recorded: \(recordedDuration)s, expected play time: \(totalPlayTime)s")
    }
}
