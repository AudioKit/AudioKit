import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {
    // Because SPM doesn't support resources yet, render out a test file.
    func generateTestFile() -> URL? {
        let osc = Oscillator(waveform: Table(.triangle))
        let engine = AudioEngine()
        engine.output = osc
        osc.start()

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("test.aiff")
        try? FileManager.default.removeItem(at: url)

        var audioFormatSettings = Settings.audioFormat.settings
        audioFormatSettings["AVLinearPCMIsNonInterleaved"] = false

        do {
            let file = try AVAudioFile(forWriting: url, settings: audioFormatSettings)
            try engine.renderToFile(file, duration: 1)
            Log("rendered test file to", url)
        } catch let error as NSError {
            Log(error, type: .error)
            return nil
        }

        return url
    }

    func testBasic() {
        guard let url = generateTestFile(),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't generate test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 2.0))
        engine.stop()

        testMD5(audio)
    }

    func testLoop() {
        guard let url = generateTestFile(),
              let buffer = try? AVAudioPCMBuffer(url: url) else {
            XCTFail("Couldn't create buffer")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true
        player.buffer = buffer

        let audio = engine.startTest(totalDuration: 2.0)
        player.play()

        audio.append(engine.render(duration: 2.0))
        engine.stop()

        testMD5(audio)
    }

    func testScheduleFile() {
        guard let url = generateTestFile() else {
            XCTFail("Didn't generate test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        player.isLooping = true

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.play()
        audio.append(engine.render(duration: 2.0))
        engine.stop()

        testMD5(audio)
    }

    func testVolume() {
        guard let url = generateTestFile(),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Couldn't create file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        player.file = file

        let audio = engine.startTest(totalDuration: 2.0)
        player.play()
        audio.append(engine.render(duration: 2.0))
        engine.stop()

        testMD5(audio)
    }

    func testSeek() {
        guard let url = generateTestFile() else {
            XCTFail("Didn't generate test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 0.5)
        player.play()
        audio.append(engine.render(duration: 2.0))
        engine.stop()
        testMD5(audio)
    }

    func testGetCurrentTime() {
        guard let url = generateTestFile() else {
            XCTFail("Didn't generate test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 0.5)
        player.play()
        
        audio.append(engine.render(duration: 2.0))
        engine.stop()

        let currentTime = player.getCurrentTime()
        XCTAssertTrue(currentTime == 0.5, "currentTime is \(currentTime), should be 0.5")

        testMD5(audio)
    }
}
