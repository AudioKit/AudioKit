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

    // for waiting in the background for realtime testing
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

        var audioFormatSettings = Settings.audioFormat.settings
        audioFormatSettings["AVLinearPCMIsNonInterleaved"] = false
        guard let file = try? AVAudioFile(forWriting: url,
                                          settings: audioFormatSettings) else {
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

    func createPlayer(duration: TimeInterval, buffered: Bool = false) -> AudioPlayer2? {
        guard let url = generateTestFile(ofDuration: duration,
                                         frequencies: chromaticScale) else {
            Log("Failed to open file")
            return nil
        }

        guard let player = AudioPlayer2(url: url, buffered: buffered) else {
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

    func testLooping() {
        realtimeLoop(buffered: false)
        realtimeLoop(buffered: true)
    }

    func testInterupts() {
        realtimeInterrupts()
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

    func realtimeLoop(buffered: Bool) {
        guard let player = createPlayer(duration: 2, buffered: buffered) else {
            XCTFail("Failed to create AudioPlayer2")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        var completionCounter = 0
        player.completionHandler = {
            if buffered {
                XCTFail("For buffer looping the completion handler isn't called. The loop is indefinite")
                return
            }
            completionCounter += 1
            Log("🏁 Completion Handler", completionCounter)
        }

        player.isLooping = true
        player.play()

        wait(for: 5)
        player.stop()
    }

    func realtimeInterrupts() {
        guard let player = createPlayer(duration: 4, buffered: false) else {
            XCTFail("Failed to create AudioPlayer2")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.play()
        wait(for: 2)

        guard let url2 = generateTestFile(ofDuration: 2,
                                          frequencies: [220, 440]) else {
            XCTFail("Failed to create file")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url2)
            try player.load(file: file)
            XCTAssertNotNil(player.file, "File is nil")

        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed loading AVAudioFile")
        }

        wait(for: 1.5)

        guard let url3 = generateTestFile(ofDuration: 3,
                                          frequencies: [880, 220]) else {
            XCTFail("Failed to create file")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url3)
            try player.load(file: file, buffered: true)
            XCTAssertNotNil(player.buffer, "Buffer is nil")
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed loading AVAudioFile")
        }

        wait(for: 2)

        guard let url4 = generateTestFile(ofDuration: 3,
                                          frequencies: chromaticScale),
            let buffer = try? AVAudioPCMBuffer(url: url4) else {
            XCTFail("Failed to create file or buffer")
            return
        }

        player.buffer = buffer

        wait(for: 1.5)

        guard let url5 = generateTestFile(ofDuration: 1,
                                          frequencies: chromaticScale.reversed()),
            let file = try? AVAudioFile(forReading: url5) else {
            XCTFail("Failed to create file or buffer")
            return
        }

        player.file = file

        wait(for: 2)
        cleanup()
    }
}

extension AudioPlayer2Tests {
    func testZZZRemoveTempFiles() {
        cleanup()
    }
}
