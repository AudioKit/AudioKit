import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {
    func testBasic() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 5.0))

        testMD5(audio)
    }

    func testLoop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            XCTFail("Couldn't create buffer")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true
        player.buffer = buffer

        let audio = engine.startTest(totalDuration: 10.0)
        player.play()

        audio.append(engine.render(duration: 10.0))

        testMD5(audio)
    }

    func testPlayAfterPause() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 2.0))
        player.pause()
        audio.append(engine.render(duration: 1.0))
        player.play()
        audio.append(engine.render(duration: 2.0))

        testMD5(audio)
    }

    func testEngineRestart() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 2.0))
        player.stop()
        engine.stop()
        _ = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        player.play()
        audio.append(engine.render(duration: 2.0))

        testMD5(audio)
    }

    func testScheduleFile() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.play()
        audio.append(engine.render(duration: 5.0))
        engine.stop()

        testMD5(audio)
    }

    func testVolume() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        player.file = file

        let audio = engine.startTest(totalDuration: 5.0)
        player.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testSeek() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 4.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 1.0)
        player.play()
        audio.append(engine.render(duration: 4.0))
        testMD5(audio)
    }

    func testCurrentTime() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

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

        let currentTime = player.currentTime
        XCTAssertEqual(currentTime, 2.5)

        testMD5(audio)
    }

    func testToggleEditTime() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 1.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.editStartTime = 0.5
        player.editEndTime = 0.6

        player.play()

        let onStartTime = player.editStartTime
        let onEndTime = player.editEndTime
        XCTAssertEqual(onStartTime, 0.5)
        XCTAssertEqual(onEndTime, 0.6)

        player.isEditTimeEnabled = false

        let offStartTime = player.editStartTime
        let offEndTime = player.editEndTime
        XCTAssertEqual(offStartTime, 0)
        XCTAssertEqual(offEndTime, player.file?.duration)

        player.isEditTimeEnabled = true

        let nextOnStartTime = player.editStartTime
        let nextOnEndTime = player.editEndTime
        XCTAssertEqual(nextOnStartTime, 0.5)
        XCTAssertEqual(nextOnEndTime, 0.6)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSwitchFilesDuringPlayback() {
        guard let url1 = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        guard let url2 = Bundle.module.url(forResource: "TestResources/chromaticScale-1", withExtension: "aiff") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 3.0)
        do {
            try player.load(url: url1)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()

        do {
            try player.load(url: url2)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        audio.append(engine.render(duration: 3.0))
        testMD5(audio)
    }
}
