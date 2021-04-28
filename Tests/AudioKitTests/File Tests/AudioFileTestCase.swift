import AudioKit
import AVFoundation
import CAudioKit
import XCTest

/// Base Test Case for file based testing such as with AudioPlayer
/// See Node Tests/Player Tests
class AudioFileTestCase: XCTestCase {
    // C4 - C5
    let chromaticScale: [AUValue] = [261.63, 277.18, 293.66, 311.13, 329.63,
                                     349.23, 369.99, 392, 415.3, 440,
                                     466.16, 493.88] // , 523.25

    static var tempFiles = [URL]()

    // search for the TestResources folder relative to the swift file containing the test
    lazy var resourceURL: URL? = {
        var url = URL(fileURLWithPath: #file)

        while true {
            url = url.deletingLastPathComponent()

            if let files = try? FileManager.default.contentsOfDirectory(atPath: url.path) {
                if files.contains("TestResources") {
                    return url.appendingPathComponent("TestResources")
                }
            }
            if url.path.count <= 1 { break } // / root directory, we failed
        }
        return nil
    }()

    lazy var countingURL: URL? = {
        resourceURL?.appendingPathComponent("12345.wav")
    }()

    lazy var drumloopURL: URL? = {
        resourceURL?.appendingPathComponent("drumloop.wav")
    }()

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {
        // remove temp files
        cleanup()
    }

    // Render a test file that contains enough variety (a scale) so you can have
    // suitable content for real time testing
    func generateTestFile(named name: String = "_io_audiokit_AudioFileTestCase_temp",
                          ofDuration duration: TimeInterval = 2,
                          frequencies: [AUValue]? = nil) -> URL? {
        let frequencies = frequencies ?? chromaticScale
        guard frequencies.count > 0 else { return nil }

        let pitchDuration = AUValue(duration) / AUValue(frequencies.count)

        // Log("duration", duration, "pitchDuration", pitchDuration)

        let osc = Oscillator(waveform: Table(.square))
        let engine = AudioEngine()
        engine.output = osc

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name)-\(AudioFileTestCase.tempFiles.count).aiff")

        // overwrite if exists
        try? FileManager.default.removeItem(at: url)

        var audioFormatSettings = Settings.audioFormat.settings
        audioFormatSettings["AVLinearPCMIsNonInterleaved"] = false
        guard let file = try? AVAudioFile(forWriting: url,
                                          settings: audioFormatSettings) else {
            return nil
        }

        var startTime: AUValue = 0
        var notes = [AutomationEvent]()
        for pitch in frequencies {
            notes.append(AutomationEvent(targetValue: pitch, startTime: startTime, rampDuration: 0))
            startTime += pitchDuration
        }

        let zero = [AutomationEvent(targetValue: 0,
                                    startTime: 0,
                                    rampDuration: 0)]
        let fadeIn = [AutomationEvent(targetValue: 1,
                                      startTime: 0,
                                      rampDuration: pitchDuration)]
        let fadeOut = [AutomationEvent(targetValue: 0,
                                       startTime: AUValue(duration) - pitchDuration,
                                       rampDuration: pitchDuration)]

        // Log(name, "duration", duration, "notes will play at", notes.map { $0.startTime })

        try? engine.avEngine.render(to: file, duration: duration, prerender: {
            osc.start()
            osc.$amplitude.automate(events: zero + fadeIn + fadeOut)
            osc.$frequency.automate(events: notes)
        })
        // Log("rendered test file to \(url)")

        AudioFileTestCase.tempFiles.append(url)
        return url
    }

    // for waiting in the background for realtime testing
    func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }

    func createError(message: String, code: Int = 1) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "io.audiokit.AudioFileTestCase.error",
                       code: code,
                       userInfo: userInfo)
    }

    func cleanup() {
        Log("Removing", AudioFileTestCase.tempFiles.count, "file(s)")
        for url in AudioFileTestCase.tempFiles {
            try? FileManager.default.removeItem(at: url)
        }
    }
}
