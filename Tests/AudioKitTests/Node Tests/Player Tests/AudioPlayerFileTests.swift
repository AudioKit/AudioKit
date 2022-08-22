import AudioKit
import AVFoundation
import XCTest

class AudioPlayerFileTests: AudioFileTestCase {
    // Bypass tests for automated CI
    var realtimeEnabled = false

    func createPlayer(duration: TimeInterval,
                      buffered: Bool = false) -> AudioPlayer?
    {
        guard let url = Bundle.module.url(forResource: "chromaticScale-\(Int(duration))", withExtension: "aiff", subdirectory: "TestResources") else {
            Log("Failed to open file")
            return nil
        }

        guard let player = AudioPlayer(url: url,
                                       buffered: buffered)
        else {
            return nil
        }
        player.volume = 0.1
        return player
    }
}

// Offline Tests - see +Realtime for the main tests

extension AudioPlayerFileTests {
    func testLoadOptions() {
        let engine = AudioEngine()
        let url = Bundle.module.url(forResource: "chromaticScale-5", withExtension: "aiff", subdirectory: "TestResources")!
        let player = AudioPlayer()
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
        let url = Bundle.module.url(forResource: "chromaticScale-1", withExtension: "aiff", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        player.play()
        XCTAssertTrue(player.status == .stopped, "Player should be stopped")

        let engine = AudioEngine()
        engine.output = player
        try? engine.start()
        player.play()
        XCTAssertTrue(player.status == .playing, "Player should be playing")
        player.stop()
    }

    func testBufferCreated() {
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        try? engine.start()
        // load a buffer
        guard let url = Bundle.module.url(forResource: "twoNotes-1", withExtension: "aiff", subdirectory: "TestResources"),
              let file = try? AVAudioFile(forReading: url),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            XCTFail("Failed to create file or buffer")
            return
        }

        // will set isBuffered to true
        player.buffer = buffer
        XCTAssertTrue(player.isBuffered, "isBuffered isn't true")
        XCTAssertTrue(player.duration == file.duration, "Duration is wrong, \(player.duration) != \(file.duration)")
    }

    func testAVDynamicConnection() {
        guard let url = Bundle.module.url(forResource: "twoNotes-2", withExtension: "aiff", subdirectory: "TestResources"),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            XCTFail("Failed to create buffer")
            return
        }

        let engine = AVAudioEngine()
        let outputMixer = AVAudioMixerNode()

        engine.attach(outputMixer)
        engine.connect(outputMixer, to: engine.mainMixerNode, format: nil)

        // Start the engine here and this breaks.
        // try! engine.start()

        let player = AVAudioPlayerNode()
        let mixer = AVAudioMixerNode()

        engine.attach(mixer)
        engine.connect(mixer, to: outputMixer, format: nil)
        engine.attach(player)
        engine.connect(player, to: mixer, format: nil)

        player.scheduleBuffer(buffer, completionHandler: nil)

        // Start here and test passes.
        try! engine.start()

        // player.play()
        // sleep(6)
    }

    /*
         // player isn't connected error in this
        func testPlayerConnectionWithMixer() {
            let engine = AudioEngine()
            let outputMixer = Mixer()
            guard let player = createPlayer(duration: 1) else {
                XCTFail("Failed to create AudioPlayer")
                return
            }
            outputMixer.addInput(player)
            engine.output = outputMixer
            let audio = engine.startTest(totalDuration: 2.0)

            player.play()

            audio.append(engine.render(duration: 1.0))

            guard let player2 = createPlayer(duration: 1) else {
                XCTFail("Failed to create AudioPlayer")
                return
            }
            let localMixer = Mixer()

            localMixer.addInput(player2)
            outputMixer.addInput(localMixer)

            player2.play()
            audio.append(engine.render(duration: 1.0))

            testMD5(audio)
            audio.audition()
        }
     */
}
