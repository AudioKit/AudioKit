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

        var outFile = try? AVAudioFile(
            forWriting: url,
            settings: settings)

        let engine = AudioEngine()
        if #available(iOS 13.0, *) {
            let osc = PlaygroundOscillator()
            osc.start()
            let recorder = try? NodeRecorder(node: osc)
            recorder?.openFile(file: &outFile)
            engine.output = osc
            try? recorder?.record()
            try! engine.start()
            sleep(2)
            recorder?.stop()
            engine.stop()
        } else {
            // Fallback on earlier versions
        }
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
}
