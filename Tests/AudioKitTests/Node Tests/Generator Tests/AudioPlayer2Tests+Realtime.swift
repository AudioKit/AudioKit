import AudioKit
import AVFoundation
import CAudioKit
import XCTest

// Real time functions, for local testing only.
// These simulate a user interacting with the player via an UI
// Real time functions, for local testing only

// Thse are organized like this so they're easy to comment out for the moment for CI tests
extension AudioPlayer2Tests {
    func testFindResources() {
        XCTAssertNotNil(countingURL != nil)
    }
    
    func testPause() {
        realtimeTestPause()
    }

    func testScheduled() {
        realtimeScheduleFile()
    }

    func testFileLooping() {
        realtimeLoop(buffered: false, duration: 2)
    }

    func testBufferLooping() {
        realtimeLoop(buffered: true, duration: 1)
    }

    func testInterrupts() {
        realtimeInterrupts()
    }

    func testFileEdits() {
        realtimeTestEdited(buffered: false)
    }

    func testBufferedEdits() {
        realtimeTestEdited(buffered: true)
    }

    func testReversed() {
        realtimeTestReversed(from: 1, to: 3)
    }
    
    func testSeek() {
        realtimeTestSeek(buffered: false)
    }

    func testSeekBuffered() {
        realtimeTestSeek(buffered: true)
    }
    
}

extension AudioPlayer2Tests {
    func realtimeTestReversed(from startTime: TimeInterval = 0, to endTime: TimeInterval = 0) {
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
        wait(for: player.duration + 1)
    }

    func realtimeTestEdited(buffered: Bool = false, reversed: Bool = false) {
        let duration = TimeInterval(chromaticScale.count)

        guard let player = createPlayer(duration: duration,
                                        buffered: buffered) else {
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

        for i in 0 ..< chromaticScale.count {
            let startTime = TimeInterval(i)
            let endTime = TimeInterval(i + 1)

            Log(startTime, "to", endTime, "duration", duration)
            player.play(from: startTime, to: endTime, at: nil)
            wait(for: 2)
        }

        Log("Done")
    }

    func realtimeTestPause() {
        guard let player = createPlayer(duration: 6) else {
            XCTFail("Failed to create AudioPlayer")
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
        player.play(at: AVAudioTime.now().offset(seconds: 3))

        wait(for: player.duration + 4)

        // test schedule separated from play
        player.schedule(at: AVAudioTime.now().offset(seconds: 3))
        player.play()

        wait(for: player.duration + 4)

        XCTAssertEqual(completionCounter, 2, "Completion handler wasn't called on both completions")
    }

    func realtimeLoop(buffered: Bool, duration: TimeInterval) {
        guard let player = createPlayer(duration: duration,
                                        frequencies: [220, 440, 444, 440],
                                        buffered: buffered) else {
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

        wait(for: 5)
        player.stop()
    }

    func realtimeInterrupts() {
        guard let player = createPlayer(duration: 4, buffered: false) else {
            XCTFail("Failed to create AudioPlayer")
            return
        }
        let engine = AudioEngine()
        engine.output = player
        try? engine.start()

        player.isLooping = true
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
        guard let url4 = generateTestFile(ofDuration: 3,
                                          frequencies: chromaticScale),
            let buffer = try? AVAudioPCMBuffer(url: url4) else {
            XCTFail("Failed to create file or buffer")
            return
        }

        // will set isBuffered to true
        player.buffer = buffer
        XCTAssertTrue(player.isBuffered, "isBuffered isn't correct")

        wait(for: 1.5)

        // load a file after a buffer
        guard let url5 = generateTestFile(ofDuration: 1,
                                          frequencies: chromaticScale.reversed()),
            let file = try? AVAudioFile(forReading: url5) else {
            XCTFail("Failed to create file or buffer")
            return
        }

        player.buffer = nil
        player.file = file

        XCTAssertFalse(player.isBuffered, "isBuffered isn't correct")

        wait(for: 2)
        cleanup()
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

        player.completionHandler = { Log("🏁 Completion Handler") }
        player.isBuffered = buffered
        
        player.seek(time: 1)
        player.play()
        
        wait(for: 2)
        player.pause()
        wait(for: 1)
        
        player.seek(time: 3)
        player.play()
        
        wait(for: 3)
    }
}
