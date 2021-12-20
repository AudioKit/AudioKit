import Foundation
import AVFoundation
import AudioKit
import XCTest

class AVAudioPCMBufferTests: XCTestCase {
    func testAppend() {
        let path = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")
        let file = try! AVAudioFile(forReading: path!)

        let fileBuffer = file.toAVAudioPCMBuffer()!
        let loopBuffer = AVAudioPCMBuffer(pcmFormat: fileBuffer.format, frameCapacity: 2 * UInt32(file.length))!

        loopBuffer.append(fileBuffer)
        XCTAssertNoThrow(loopBuffer.append(fileBuffer))
    }

    func doTestM4A(url: URL) {

        var settings = Settings.audioFormat.settings
        settings[AVFormatIDKey] = kAudioFormatMPEG4AAC
        settings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)

        let outFile = try! AVAudioFile(
            forWriting: url,
            settings: settings)

        let engine = AudioEngine()
        let osc = PlaygroundOscillator()
        osc.start()
        let recorder = try! NodeRecorder(node: osc, file: outFile)
        engine.output = osc
        try! recorder.record()
        try! engine.start()
        sleep(2)
        recorder.stop()
        engine.stop()
    }

    func testM4A() {

        let fm = FileManager.default

        let filename = UUID().uuidString + ".m4a"
        let fileUrl = fm.temporaryDirectory.appendingPathComponent(filename)

        doTestM4A(url: fileUrl)

        print("fileURL: \(fileUrl)")

        let inFile = try! AVAudioFile(forReading: fileUrl)
        XCTAssertTrue(inFile.length > 0)

    }

    func testPlayerToM4A() {

        self.continueAfterFailure = false // causes XCTFail to abort the test

        NodeRecorder.removeTempFiles() // just make sure the temp dir exists

        let inputFileURL = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav")!

        XCTAssertTrue(FileManager.default.fileExists(atPath: inputFileURL.path), "inputFileURL does not exist")

        let fm = FileManager.default
        let filename = UUID().uuidString + ".m4a"
        let outputFileURL = fm.temporaryDirectory.appendingPathComponent(filename)

        let player = AudioPlayer(url: inputFileURL)!

        let engine = AudioEngine()
        engine.output = player
        try! engine.start()

        player.play()

        var settings = Settings.audioFormat.settings
        settings[AVFormatIDKey] = kAudioFormatMPEG4AAC
        settings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)

        var outFile: AVAudioFile!
        do {
            outFile = try AVAudioFile(forWriting: outputFileURL, settings: settings)
        } catch {
            XCTFail("could not create outFile: \(error.localizedDescription)")
        }

        XCTAssertTrue(FileManager.default.fileExists(atPath: outFile.url.path), "outFile does not exist")

        var recorder: NodeRecorder!
        do {
            recorder = try NodeRecorder(node: player, file: outFile)
        } catch {
            XCTFail("could not create recorder: \(error.localizedDescription)")
        }

        do {
            try recorder.record()
        } catch {
            XCTFail("could not run recorder.record(): \(error.localizedDescription)")
        }

        sleep(6) // a little longer than 2 seconds to allow some wiggle room

        player.stop()
        recorder.stop()
        engine.stop()

        var successFile: AVAudioFile!
        do {
            successFile = try AVAudioFile(forReading: outputFileURL)
        } catch {
            XCTFail("could not create successFile: \(error.localizedDescription)")
        }

        XCTAssertTrue(successFile.length > 0, "successFile length is not > 0")

        print ("*** Created m4a file?: \(recorder.audioFile?.url)")
    }
}
