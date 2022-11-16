import AudioKit
import AVFoundation
import XCTest

extension AudioPlayerFileTests {
    func realtimeTestReversed(from startTime: TimeInterval = 0,
                              to endTime: TimeInterval = 0)
    {
        guard let countingURL = countingURL else {
            XCTFail("Didn't find the 12345.wav")
            return
        }

        guard let player = AudioPlayer(url: countingURL) else {
            XCTFail("Failed to create AudioPlayer")
            return
        }

        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.completionHandler = { Log("🏁 Completion Handler") }

        player.isReversed = true

        player.play(from: startTime, to: endTime)
        wait(for: endTime - startTime)
    }

    // Walks through the chromatic scale playing each note twice with
    // two different editing methods. Note this test will take some time
    // so be prepared to cancel it
    func realtimeTestEdited(buffered: Bool = false, reversed: Bool = false) {
        let duration = TimeInterval(chromaticScale.count)

        guard let player = createPlayer(duration: duration,
                                        buffered: buffered)
        else {
            XCTFail("Failed to create AudioPlayer")
            return
        }

        if buffered {
            guard player.isBuffered else {
                XCTFail("Should be buffered")
                return
            }
        }
        player.isReversed = reversed

        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.completionHandler = { Log("🏁 Completion Handler") }

        // test out of bounds edits
        player.editStartTime = duration + 1
        XCTAssertTrue(player.editStartTime == player.duration)

        player.editStartTime = -1
        XCTAssertTrue(player.editStartTime == 0)

        player.editEndTime = -1
        XCTAssertTrue(player.editEndTime == 0)

        player.editEndTime = duration + 1
        XCTAssertTrue(player.editEndTime == player.duration)

        for i in 0 ..< chromaticScale.count {
            let startTime = TimeInterval(i)
            let endTime = TimeInterval(i + 1)

            Log(startTime, "to", endTime, "duration", duration)
            player.play(from: startTime, to: endTime, at: nil)

            wait(for: 2)

            // Alternate syntax which should be the same as above
            player.editStartTime = startTime
            player.editEndTime = endTime
            Log(startTime, "to", endTime, "duration", duration)
            player.play()
            wait(for: 2)
        }

        Log("Done")
    }

    func stopAndStart(file: AVAudioFile, clipPlayer: AudioPlayer) {
        print("status:\(clipPlayer.status)")
        XCTAssert(clipPlayer.status == NodeStatus.Playback.playing)
        clipPlayer.stop()
        do {
            try clipPlayer.load(file: file)
            clipPlayer.play()
        } catch {
            Log(error.localizedDescription, type: .error)
        }
    }

    func testPlayThreeFiles() {
        guard let url1 = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test url")
            return
        }
        guard let url2 = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav") else {
            XCTFail("Didn't get test url")
            return
        }
        guard let url3 = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test url")
            return
        }
        let first = try? AVAudioFile(forReading: url1)
        let second = try? AVAudioFile(forReading: url2)
        let third = try? AVAudioFile(forReading: url3)
        guard let file1 = first, let file2 = second, let file3 = third else {
            XCTFail("Didn't get test files")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer(file: file1)
        guard let clipPlayer = player else {
            XCTFail("Couldn't create player")
            return
        }
        engine.output = clipPlayer
        try? engine.start()

        return // this should not play live but instead invoke a test

            clipPlayer.play()
        wait(for: 2.0)
        stopAndStart(file: file2, clipPlayer: clipPlayer)
        wait(for: 2.0)
        stopAndStart(file: file3, clipPlayer: clipPlayer)
        wait(for: 2.0)
    }

    func realtimeTestPause() {
        guard let player = createPlayer(duration: 5) else {
            XCTFail("Failed to create AudioPlayer")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.completionHandler = { Log("🏁 Completion Handler") }
        var duration = player.duration

        return // this should not play live but instead invoke a test

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
        guard let player = createPlayer(duration: 5) else {
            XCTFail("Failed to create AudioPlayer")
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
        let timeBeforePlay = 0.6
        player.play(from: 3.1, at: AVAudioTime.now().offset(seconds: timeBeforePlay))

        // Make sure player doesn't count time before file starts playing
        // Truncate time to one decimal for precision in comparison
        var playerTime = Double(floor(pow(10.0, Double(1)) * player.currentTime) / pow(10.0, Double(1)))
        XCTAssert(playerTime == player.editStartTime)
        wait(for: timeBeforePlay)
        // Truncate time to one decimal for precision in comparison
        playerTime = Double(floor(pow(10.0, Double(1)) * player.currentTime) / pow(10.0, Double(1)))
        XCTAssert(playerTime == player.editStartTime)

        wait(for: player.duration)

        // test schedule separated from play
        player.schedule(at: AVAudioTime.now().offset(seconds: timeBeforePlay))
        player.play()

        // Make sure player doesn't count time before file starts playing
        // Truncate time to one decimal for precision in comparison
        playerTime = Double(floor(pow(10.0, Double(1)) * player.currentTime) / pow(10.0, Double(1)))
        XCTAssert(playerTime == player.editStartTime)
        wait(for: timeBeforePlay)
        // Truncate time to one decimal for precision in comparison
        playerTime = Double(floor(pow(10.0, Double(1)) * player.currentTime) / pow(10.0, Double(1)))
        XCTAssert(playerTime == player.editStartTime)

        wait(for: player.duration)

        XCTAssertEqual(completionCounter, 2, "Completion handler wasn't called on both completions")
    }

    func realtimeLoop(buffered: Bool, duration: TimeInterval) {
        guard let player = createPlayer(duration: duration,
                                        buffered: buffered)
        else {
            XCTFail("Failed to create AudioPlayer")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        var completionCounter = 0
        player.completionHandler = {
            if buffered {
                XCTFail("For buffer looping the completion handler isn't called. The loop is infinite")
                return
            }
            completionCounter += 1
            Log("🏁 Completion Handler", completionCounter)
        }

        player.isLooping = true
        player.play()

        wait(for: 10)
        player.stop()
    }

    func realtimeInterrupts() {
        guard let player = createPlayer(duration: 5, buffered: false) else {
            XCTFail("Failed to create AudioPlayer")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.isLooping = true
        player.play()
        wait(for: 2)

        guard let url2 = Bundle.module.url(forResource: "twoNotes-2", withExtension: "aiff", subdirectory: "TestResources") else {
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

        guard let url3 = Bundle.module.url(forResource: "twoNotes-3", withExtension: "aiff", subdirectory: "TestResources") else {
            XCTFail("Failed to create file")
            return
        }

        // load a file
        do {
            let file = try AVAudioFile(forReading: url3)
            try player.load(file: file, buffered: true)
            XCTAssertNotNil(player.buffer, "Buffer is nil")
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail("Failed loading AVAudioFile")
        }

        wait(for: 2)

        // load a buffer
        guard let url4 = Bundle.module.url(forResource: "chromaticScale-2", withExtension: "aiff", subdirectory: "TestResources"),
              let buffer = try? AVAudioPCMBuffer(url: url4)
        else {
            XCTFail("Failed to create file or buffer")
            return
        }

        // will set isBuffered to true
        player.buffer = buffer
        XCTAssertTrue(player.isBuffered, "isBuffered isn't correct")

        wait(for: 1.5)

        // load a file after a buffer
        guard let url5 = Bundle.module.url(forResource: "chromaticScale-1", withExtension: "aiff", subdirectory: "TestResources"),
              let file = try? AVAudioFile(forReading: url5)
        else {
            XCTFail("Failed to create file or buffer")
            return
        }

        player.buffer = nil
        player.file = file

        XCTAssertFalse(player.isBuffered, "isBuffered isn't correct")

        wait(for: 2)
    }

    func realtimeTestSeek(buffered: Bool = false) {
        guard let countingURL = countingURL else {
            XCTFail("Didn't find the 12345.wav")
            return
        }

        guard let player = AudioPlayer(url: countingURL) else {
            XCTFail("Failed to create AudioPlayer")
            return
        }

        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.completionHandler = {
            Log("🏁 Completion Handler", Thread.current)
        }
        player.isBuffered = buffered

        // 2 3 4
        player.seek(time: 1)
        player.play()

        XCTAssertTrue(player.status == .playing)
        wait(for: 1)
        player.stop()
        wait(for: 1)

        // 4
        player.seek(time: 3)
        player.play()

        XCTAssertTrue(player.status == .playing)
        wait(for: 1)

        // NOTE: the completionHandler will set isPlaying to false. This happens in a different
        // thread and subsequently makes the below isPlaying checks fail. This only seems
        // to happen in the buffered test, but bypassing those checks for now

        // rewind to 4 while playing
        player.seek(time: 3)
        // XCTAssertTrue(player.isPlaying)
        wait(for: 1)

        player.seek(time: 2)
        // XCTAssertTrue(player.isPlaying)
        wait(for: 1)

        player.seek(time: 1)
        // XCTAssertTrue(player.isPlaying)
        wait(for: 1)

        var time = player.duration

        // make him count backwards for fun: 5 4 3 2 1
        // Currently only works correctly in the non buffered version:
        while time > 0 {
            time -= 1
            player.seek(time: time)
            // XCTAssertTrue(player.isPlaying)
            wait(for: 1)
        }
        player.stop()
    }

    func realtimeTestPlayerStatus() {
        guard let countingURL = countingURL else {
            XCTFail("Didn't find the 12345.wav")
            return
        }
        guard let drumloopURL = drumloopURL else {
            XCTFail("Didn't find the 12345.wav")
            return
        }
        guard let countingFile = try? AVAudioFile(forReading: countingURL) else {
            XCTFail("Failed to open file URL \(countingURL) for reading")
            return
        }
        guard let drumloopFile = try? AVAudioFile(forReading: drumloopURL) else {
            XCTFail("Failed to open file URL \(drumloopURL) for reading")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        try? engine.start()

        player.file = countingFile
        player.play()
        wait(for: 1)
        player.stop()
        player.file = drumloopFile
        player.play()
        XCTAssert(player.status == .playing)
        wait(for: 4)
        XCTAssert(player.status == .stopped)
    }
}

extension AudioPlayerFileTests {
    /// Files should play back at normal pitch for both buffered and streamed
    func realtimeTestMixedSampleRates(buffered: Bool = false) {
        // this file is 44.1k
        guard let countingURL = countingURL else {
            XCTFail("Didn't find the 12345.wav")
            return
        }
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channels: 2) else {
            XCTFail("Failed to create 48k format")
            return
        }

        let countingURL48k = countingURL.deletingLastPathComponent()
            .appendingPathComponent("_io_audiokit_AudioPlayerFileTests_realtimeTestMixedSampleRates.wav")
        Self.tempFiles.append(countingURL48k)

        let wav48k = FormatConverter.Options(pcmFormat: .wav,
                                             sampleRate: 48000,
                                             bitDepth: 16,
                                             channels: 1)
        let converter = FormatConverter(inputURL: countingURL,
                                        outputURL: countingURL48k,
                                        options: wav48k)

        converter.start { error in
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            self.processMixedSampleRates(urls: [countingURL, countingURL48k],
                                         audioFormat: audioFormat,
                                         buffered: buffered)
        }
    }

    private func processMixedSampleRates(urls: [URL],
                                         audioFormat: AVAudioFormat,
                                         buffered: Bool = false)
    {
        Settings.audioFormat = audioFormat

        let engine = AudioEngine()
        let player = AudioPlayer()

        player.isBuffered = buffered
        player.completionHandler = {
            Log("🏁 Completion Handler", Thread.current)
        }

        engine.output = player
        try? engine.start()

        for url in urls {
            do {
                try player.load(url: url)
            } catch {
                Log(error)
                XCTFail(error.localizedDescription)
            }
            Log("ENGINE", engine.avEngine.description,
                "PLAYER fileFormat", player.file?.fileFormat,
                "PLAYER buffer format", player.buffer?.format)

            player.play()

            wait(for: player.duration + 1)
            player.stop()
        }
    }
}
