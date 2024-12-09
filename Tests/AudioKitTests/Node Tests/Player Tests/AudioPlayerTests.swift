import AudioKit
import AVFoundation
import XCTest

class AudioPlayerTests: XCTestCase {

    override func setUp() {
        Settings.sampleRate = 44100
    }

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

    func testCanStopPausedPlayback() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 3.0)
        player.file = file

        XCTAssertEqual(player.status, .stopped)
        player.play()
        XCTAssertEqual(player.status, .playing)
        audio.append(engine.render(duration: 2.0))
        player.pause()
        XCTAssertEqual(player.status, .paused)
        audio.append(engine.render(duration: 1.0))
        player.stop()
        XCTAssertEqual(player.status, .stopped)
        testMD5(audio)
    }

    func testCurrentPosition() {
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

        player.play()
        audio.append(engine.render(duration: 1.0))
        let currentPosition = (player.currentPosition * 100).rounded() / 100
        // player.duration approx = 5.48; 1.0 / 5.48 = 0.18 to 2d.p.
        XCTAssertEqual(currentPosition, 0.18)
        testMD5(audio)
    }

    func testSeekAfterPause() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        player.seek(time: 1.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(player.status, .playing)

        player.pause()
        XCTAssertEqual(player.status, .paused)

        player.play()
        player.seek(time: 1.0)
        audio.append(engine.render(duration: 1.0))
        let currentTime = player.currentTime
        XCTAssertEqual(currentTime, 4.0)
        testMD5(audio)
    }

    func testSeekAfterStop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        audio.append(engine.render(duration: 1.0))
        let currentTime1 = player.currentTime
        XCTAssertEqual(currentTime1, 1.0)

        player.stop()
        let currentTime2 = player.currentTime
        XCTAssertEqual(currentTime2, 0.0)

        player.play()
        player.seek(time: 0.5)
        audio.append(engine.render(duration: 1.0))
        let currentTime3 = player.currentTime
        XCTAssertEqual(currentTime3, 1.5)
        testMD5(audio)
    }

    func testSeekForwardsAndBackwards() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 4.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        player.seek(time: 1.0)
        audio.append(engine.render(duration: 2.0))
        let currentTime1 = player.currentTime
        XCTAssertEqual(currentTime1, 3)

        player.seek(time: -1.0)
        player.seek(time: -1.0)
        XCTAssert(player.status == .playing)

        audio.append(engine.render(duration: 1.0))
        let currentTime2 = player.currentTime
        XCTAssertEqual(currentTime2, 2)
        testMD5(audio)
    }

    func testSeekWillStop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        player.seek(time: 6.0)  // player.duration < 5.5
        audio.append(engine.render(duration: 1.0))
        XCTAssert(player.status == .stopped)

        player.play()
        audio.append(engine.render(duration: 1.0))
        XCTAssert(player.status == .playing)

        player.seek(time: -2.0)  // currentTime == 1.0
        audio.append(engine.render(duration: 1.0))
        XCTAssert(player.status == .stopped)
        testMD5(audio)
    }

    func testSeekWillContinueLooping() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true

        let audio = engine.startTest(totalDuration: 4.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        XCTAssert(player.status == .playing)

        player.seek(time: 6) // player.duration < 5.5
        audio.append(engine.render(duration: 2.0))
        XCTAssert(player.status == .playing)
        testMD5(audio)
    }

    func testPlaybackWillStopWhenSettingLoopingForBuffer() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            XCTFail("Couldn't create buffer")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.buffer = buffer
        player.isLooping = false

        let audio = engine.startTest(totalDuration: 4.0)
        player.play()

        player.play()
        audio.append(engine.render(duration: 2.0))
        XCTAssert(player.status == .playing)

        player.isLooping = false
        audio.append(engine.render(duration: 2.0))
        XCTAssert(player.status == .stopped)
        testMD5(audio)
    }

    // https://github.com/AudioKit/AudioKit/issues/2916
    func testCompletionHandler() {
        guard let counting = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav")
        else {
            XCTFail("Couldn't find file")
            return
        }
        guard let drumLoop = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")
        else {
            XCTFail("Couldn't find file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.completionHandler = {
            try? player.load(url: drumLoop)
            player.play()
        }
        try? player.load(url: counting)
        let audio = engine.startTest(totalDuration: 9.0)
        player.play()
        audio.append(engine.render(duration: 9.0))
        testMD5(audio)
    }
}
