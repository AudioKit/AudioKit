// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

#if !os(tvOS)
/// Tests for engine.inputNode - note can't be tested without an Info.plist
class RecordingTests: AudioFileTestCase {
    func testMultiChannelRecording() throws {
        guard Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil else {
            Log("Unsupported test: To record audio, you must include the NSMicrophoneUsageDescription in your Info.plist.",
                type: .error)
            return
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("_testMultiChannelRecording")

        if !FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.createDirectory(at: url,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        }

        let expectation = XCTestExpectation(description: "recordWithPermission")

        AVCaptureDevice.requestAccess(for: .audio) { allowed in
            Log("requestAccess", allowed)
            do {
                // Record channels 3+4 in a multichannel device
                // let channelMap: [Int32] = [2, 3]
                // for test assume mono first channel
                let channelMap: [Int32] = [0]
                try self.recordWithLatency(url: url, channelMap: channelMap, ioLatency: 12345)
                expectation.fulfill()

            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        try FileManager.default.removeItem(at: url)
        wait(for: [expectation], timeout: 10)
    }

    /// unable to test this in AudioKit due to the lack of the Info.plist, but this should be addressed
    func recordWithLatency(url: URL, channelMap: [Int32], ioLatency: AVAudioFrameCount = 0) throws {
        // pull from channels 3+4 - needs to work with the device being tested
        // var channelMap: [Int32] = [2, 3] // , 4, 5

        let engine = AudioEngine()

        let channelMap: [Int32] = [0] // mono first channel

        let recorder = MultiChannelInputNodeTap(inputNode: engine.avEngine.inputNode)
        recorder.ioLatency = ioLatency
        try engine.start()
        recorder.directory = url
        recorder.prepare(channelMap: channelMap)
        recorder.record()

        wait(for: 3)

        recorder.stop()
        recorder.recordEnabled = false

        wait(for: 1)

        engine.stop()
    }

    func createFileURL() -> URL {
        let fileManager = FileManager.default
        let filename = UUID().uuidString + ".m4a"
        let fileUrl = fileManager.temporaryDirectory.appendingPathComponent(filename)
        return fileUrl
    }

    func getSettings() -> [String: Any] {
        var settings = Settings.audioFormat.settings
        settings[AVFormatIDKey] = kAudioFormatMPEG4AAC
        settings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)
        return settings
    }

    func testOpenCloseFile() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }

        let fileURL = createFileURL()
        let settings = getSettings()

        var outFile = try? AVAudioFile(
            forWriting: fileURL,
            settings: settings)

        let engine = AudioEngine()
        let input = AudioPlayer(file: file)
        guard let input = input else {
            XCTFail("Couldn't load input Node.")
            return
        }

        let recorder = try? NodeRecorder(node: input)
        recorder?.openFile(file: &outFile)
        let player = AudioPlayer()
        engine.output = input

        try? engine.start()

        return // this should not play live but instead invoke a test

        input.start()
        try? recorder?.record()
        wait(for: 2)

        recorder?.stop()
        input.stop()
        engine.stop()

        engine.output = player
        recorder?.closeFile(file: &outFile)

        guard let recordedFile = recorder?.audioFile else {
            XCTFail("Couldn't open recorded audio file!")
            return
        }
        wait(for: 2)

        player.file = recordedFile
        try? engine.start()
        player.play()
        wait(for: 2)
    }

    func testPauseRecording() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }

        let fileURL = createFileURL()
        let settings = getSettings()

        var outFile = try? AVAudioFile(
            forWriting: fileURL,
            settings: settings)

        let engine = AudioEngine()
        let player = AudioPlayer(file: file)
        guard let player = player else {
            XCTFail("Couldn't load input Node.")
            return
        }

        let recorder = try? NodeRecorder(node: player)
        recorder?.openFile(file: &outFile)
        engine.output = player

        try? engine.start()


        return // this should not play live but instead invoke a test

        player.play()
        try? recorder?.record()
        wait(for: 1.5)

        recorder?.pause()
        wait(for: 1.2)

        recorder?.resume()
        wait(for: 1.2)

        recorder?.stop()
        player.stop()
        engine.stop()
        engine.output = player

        recorder?.closeFile(file: &outFile)

        guard let recordedFile = recorder?.audioFile else {
            XCTFail("Couldn't open recorded audio file!")
            return
        }
        wait(for: 1)

        player.file = recordedFile
        try? engine.start()
        // 1, 2, 4
        player.play()
        wait(for: 3)
    }

    func testReset() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url) else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer(file: file)

        guard let player = player else {
            XCTFail("Couldn't load input Node.")
            return
        }

        let recorder = try? NodeRecorder(node: player)
        engine.output = player
        try? engine.start()

        return // this should not play live but instead invoke a test


        player.play()
        try? recorder?.record()
        wait(for: 1.5)

        // Pause for fun
        recorder?.pause()

        // Try to reset and record again
        try? recorder?.reset()
        try? recorder?.record()
        wait(for: 1.2)

        recorder?.stop()
        player.stop()
        engine.stop()
        engine.output = player

        guard let recordedFile = recorder?.audioFile else {
            XCTFail("Couldn't open recorded audio file!")
            return
        }
        wait(for: 1)

        player.file = recordedFile


        try? engine.start()
        // 3
        player.play()
        wait(for: 3)
    }
}
#endif
