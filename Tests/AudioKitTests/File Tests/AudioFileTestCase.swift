import AudioKit
import AVFoundation
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

    lazy var countingURL: URL? = resourceURL?.appendingPathComponent("12345.wav")

    lazy var drumloopURL: URL? = resourceURL?.appendingPathComponent("drumloop.wav")

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {
        // remove temp files
        cleanup()
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
        for url in Self.tempFiles {
            Log("🗑 Removing", url.path)
            // try? FileManager.default.removeItem(at: url)
        }
    }
}
