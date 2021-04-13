import AudioKit
import AVFoundation
import XCTest

class PhaseLockedVocoderTests: XCTestCase {

    // Because SPM doesn't support resources yet, render out a test file.
    func generateTestFile() -> URL {

        let osc = Oscillator(waveform: Table(.triangle))
        let engine = AudioEngine()
        engine.output = osc
        osc.start()
        osc.$frequency.ramp(to: 880, duration: 1.0)

        let mgr = FileManager.default
        let url = mgr.temporaryDirectory.appendingPathComponent("test.aiff")
        try? mgr.removeItem(at: url)
        let file = try! AVAudioFile(forWriting: url, settings: Settings.audioFormat.settings)

        try! engine.renderToFile(file, duration: 1)
        print("rendered test file to \(url)")

        return url
    }

    func testDefault() {
        let url = generateTestFile()

        XCTAssertNotNil(url)

        let file = try! AVAudioFile(forReading: url)

        let engine = AudioEngine()
        let vocoder = PhaseLockedVocoder(file: file)
        engine.output = vocoder

        let audio = engine.startTest(totalDuration: 2.0)
        vocoder.$position.ramp(to: 0.5, duration: 0.5)
        audio.append(engine.render(duration: 1.0))
        vocoder.$position.ramp(to: 0, duration: 0.5)
        audio.append(engine.render(duration: 1.0))

        engine.stop()

        testMD5(audio)
    }
}
