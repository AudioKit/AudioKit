import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class AudioPlayer2Tests: XCTestCase {
    // C4 - C5
    let chromaticScale: [AUValue] = [261.63, 277.18, 293.66, 311.13, 329.63,
                                     349.23, 369.99, 392, 415.3, 440,
                                     466.16, 493.88] // , 523.25

    private static var tempFiles = [URL]()

    func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }

    func generateTestFile(named name: String = "_io_audiokit_AudioPlayer2Tests_temp",
                          ofDuration duration: TimeInterval = 2,
                          frequencies: [AUValue]? = nil) -> URL? {
        let frequencies = frequencies ?? chromaticScale
        guard frequencies.count > 0 else { return nil }

        let pitchDuration = AUValue(duration) / AUValue(frequencies.count)

        Log("duration", duration, "pitchDuration", pitchDuration)

        let osc = Oscillator(waveform: Table(.square))
        let engine = AudioEngine()
        engine.output = osc

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(name)-\(AudioPlayer2Tests.tempFiles.count).aiff")
        try? FileManager.default.removeItem(at: url)

        guard let file = try? AVAudioFile(forWriting: url,
                                          settings: Settings.defaultAudioFormat.settings) else {
            return nil
        }

        var startTime: AUValue = 0
        var notes = [AutomationEvent]()
        for pitch in frequencies {
            notes.append(AutomationEvent(targetValue: pitch, startTime: startTime, rampDuration: 0))
            startTime += pitchDuration
        }

        let zero = [AutomationEvent(targetValue: 0, startTime: 0, rampDuration: 0)]
        let fadeIn = [AutomationEvent(targetValue: 1, startTime: 0, rampDuration: pitchDuration)]
        let fadeOut = [AutomationEvent(targetValue: 0, startTime: AUValue(duration) - pitchDuration, rampDuration: pitchDuration)]

        Log(name, "duration", duration, "notes will play at", notes.map { $0.startTime })

        try? engine.avEngine.render(to: file, duration: duration, prerender: {
            osc.start()
            osc.$amplitude.automate(events: zero + fadeIn + fadeOut)
            osc.$frequency.automate(events: notes)
        })
        Log("rendered test file to \(url)")

        AudioPlayer2Tests.tempFiles.append(url)
        return url
    }

    func createPlayer(duration: TimeInterval) -> AudioPlayer2? {
        guard let url = generateTestFile(ofDuration: duration,
                                         frequencies: chromaticScale) else {
            Log("Failed to open file")
            return nil
        }

        guard let player = AudioPlayer2(url: url) else {
            return nil
        }
        player.volume = 0.1
        return player
    }

    func cleanup() {
        for url in AudioPlayer2Tests.tempFiles {
            Log("removeItem", url)

            try? FileManager.default.removeItem(at: url)
        }
    }
}

// Actual Tests

extension AudioPlayer2Tests {
    func testLoadOptions() {
        guard let url = generateTestFile(ofDuration: 5,
                                         frequencies: chromaticScale) else {
            XCTFail("Failed to create file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer2()
        engine.output = player

        do {
            try player.load(url: url)
            XCTAssertNotNil(player.file, "File is nil")
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed loading URL")
        }

        do {
            let file = try AVAudioFile(forReading: url)
            try player.load(file: file)
            XCTAssertNotNil(player.file, "File is nil")
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed loading AVAudioFile")
        }

        do {
            try player.load(url: url, buffered: true)
            XCTAssertNotNil(player.buffer, "Buffer is nil")

        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed loading AVAudioFile")
        }
    }

    func testPlayerIsAttached() {
        guard let player = createPlayer(duration: 1) else {
            XCTFail("Failed to create AudioPlayer2")
            return
        }
        player.play()

        XCTAssertFalse(player.isPlaying, "isPlaying should be false")

        let engine = AudioEngine()
        engine.output = player
        try? engine.start()
        player.play()
        XCTAssertTrue(player.isPlaying, "isPlaying should be true")
        player.stop()
    }
}

// Real time functions, for local testing only
extension AudioPlayer2Tests {
    func testPause() {
        realtimeTestPause()
    }

    func testScheduled() {
        realtimeScheduleFile()
    }

    func realtimeTestPause() {
        guard let player = createPlayer(duration: 6) else {
            XCTFail("Failed to create AudioPlayer2")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.completionHandler = { Log("🏁 Completion Handler") }

        var duration = player.duration

        Log("▶️")
        player.play()
        wait(for: 2)
        duration -= 2

        Log("⏸")
        player.pause()
        wait(for: 1)
        duration -= 1

        Log("▶️")
        player.play()
        wait(for: duration)
        Log("⏹")
    }

    func realtimeScheduleFile() {
        guard let player = createPlayer(duration: 2) else {
            XCTFail("Failed to create AudioPlayer2")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        var completionCounter = 0
        player.completionHandler = {
            completionCounter += 1
            Log("🏁 Completion Handler", completionCounter)
        }

        // test schedule with play
        player.play(at: AVAudioTime.now().offset(seconds: 3))

        wait(for: player.duration + 3)

        // test schedule separated from play
        player.schedule(at: AVAudioTime.now().offset(seconds: 3))
        player.play()

        wait(for: player.duration + 3)

        XCTAssertEqual(completionCounter, 2, "Completion handler wasn't called on both completions")
    }

    func testFileLoop() {
        guard let player = createPlayer(duration: 2) else {
            XCTFail("Failed to create AudioPlayer2")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        var completionCounter = 0
        player.completionHandler = {
            completionCounter += 1
            Log("🏁 Completion Handler", completionCounter)
        }

        player.isLooping = true
        player.play()

        wait(for: 6)
        player.stop()
    }
}

extension AudioPlayer2Tests {
    func testZZZRemoveTempFiles() {
        cleanup()
    }
}
