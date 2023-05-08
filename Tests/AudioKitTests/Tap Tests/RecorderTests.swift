// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
import AudioKit
import AVFoundation
import XCTest

class RecorderTests: AKTestCase {

    @MainActor
    func testBasicRecord() throws {

        let mgr = FileManager.default
        var audioFileURL = mgr.temporaryDirectory.appendingPathComponent("testBasicRecord.aiff", conformingTo: .aiff)

        try? mgr.removeItem(at: audioFileURL)

        let scope = {
            let engine = Engine()
            let sampler = Sampler()
            engine.output = sampler

            let format = AVAudioFormat(standardFormatWithSampleRate: 44100,
                                       channels: 2)!

            let file = try AVAudioFile(forWriting: audioFileURL, settings: format.settings)
            let recorder = Recorder2(node: sampler, file: file)

            recorder.isPaused = false

            // record a little audio
            try engine.start()
            sampler.play(url: .testAudio)

            RunLoop.main.run(until: .now+1.0)

            XCTAssertGreaterThan(file.length, 1024)

        }

        try scope()

        print("audioFileURL: \(audioFileURL)")
        let file = try AVAudioFile(forReading: audioFileURL)
        XCTAssertGreaterThan(file.length, 1024)
        XCTAssertFalse(file.toAVAudioPCMBuffer()!.isSilent)

    }
}
