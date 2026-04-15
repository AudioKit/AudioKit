// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class NodeRecorderTests: XCTestCase {
    /// Builds an engine + looping player wired up for offline rendering tests.
    private func makeFixture() throws -> (AudioEngine, AudioPlayer, NodeRecorder) {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        player.isLooping = true
        engine.output = player
        return (engine, player, try NodeRecorder(node: player))
    }

    func testBasicRecord() throws {
        let (engine, player, recorder) = try makeFixture()

        let audio = engine.startTest(totalDuration: 1.0)
        try recorder.record()
        player.play()
        audio.append(engine.render(duration: 1.0))
        recorder.stop()

        XCTAssertGreaterThan(recorder.audioFile?.duration ?? 0, 0)
    }

    func testCallback() throws {
        let (engine, player, recorder) = try makeFixture()

        var values = [Float]()
        recorder.audioDataCallback = { audioData, _ in
            values.append(contentsOf: audioData)
        }

        let audio = engine.startTest(totalDuration: 1.0)
        try recorder.record()
        player.play()
        audio.append(engine.render(duration: 1.0))
        recorder.stop()

        XCTAssertFalse(values.isEmpty)
    }

    /// Reproduces GitHub #2947: after multiple pause/resume cycles, the recorded
    /// duration drifts away from the expected elapsed play time because the tap
    /// block keeps firing while paused and may flush a mid-flight buffer at each
    /// boundary. Offline rendering makes the timing deterministic.
    func testPauseResumeDrift() throws {
        let (engine, player, recorder) = try makeFixture()

        let segment = 0.3
        let cycles = 10
        let totalDuration = Double(cycles * 2 + 1) * segment

        let audio = engine.startTest(totalDuration: totalDuration)
        try recorder.record()
        player.play()

        for _ in 0 ..< cycles {
            audio.append(engine.render(duration: segment))
            recorder.pause()
            audio.append(engine.render(duration: segment))
            recorder.resume()
        }
        audio.append(engine.render(duration: segment))
        recorder.stop()

        let expectedPlayDuration = Double(cycles + 1) * segment
        let recordedDuration = recorder.audioFile?.duration ?? 0
        let perCycleDrift = abs(recordedDuration - expectedPlayDuration) / Double(cycles)

        XCTAssertLessThan(perCycleDrift, 0.015,
                          "Per-cycle drift \(perCycleDrift * 1000)ms; " +
                          "recorded \(recordedDuration)s vs expected \(expectedPlayDuration)s")
    }
}
