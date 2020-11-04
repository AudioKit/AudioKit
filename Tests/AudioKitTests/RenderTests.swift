// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKit
import XCTest

class RenderTests: XCTestCase {
    func runWith(feedback: Float, silenceThreshold: Float = 0.05, format: AVAudioFormat? = nil) -> Float {
        let format = format ?? Settings.defaultAudioFormat

        let engine = AudioEngine()
        let input = Oscillator()
        let automationEvent = AutomationEvent(targetValue: 0.0, startTime: 0.9, rampDuration: 0.05)
        engine.output = CostelloReverb(input, feedback: feedback)
        input.$amplitude.automate(events: [automationEvent])
        input.start()

        let mgr = FileManager.default
        let url = mgr.temporaryDirectory.appendingPathComponent("test.aiff")
        try? mgr.removeItem(at: url)
        let file = try! AVAudioFile(forWriting: url, settings: format.settings)

        try? engine.avEngine.render(to: file,
                                    maximumFrameCount: 1_024,
                                    duration: 1.0,
                                    renderUntilSilent: true,
                                    silenceThreshold: silenceThreshold)
        return Float(file.duration)
    }

    func testShortTail() {
        XCTAssertEqual(runWith(feedback: 0.1), 1.06, accuracy: 0.01)
    }

    func testMidTail() {
        XCTAssertEqual(runWith(feedback: 0.5), 1.16, accuracy: 0.01)
    }

    func testLongestTail() {
        XCTAssertEqual(runWith(feedback: 0.9), 2.41, accuracy: 0.01)
    }

    func testShortMoreSilence() {
        XCTAssertEqual(runWith(feedback: 0.1, silenceThreshold: 0.0001), 1.18, accuracy: 0.01)
    }

    func testMidMoreSilence() {
        XCTAssertEqual(runWith(feedback: 0.5, silenceThreshold: 0.0001), 1.71, accuracy: 0.01)
    }

    func testLongMoreSilence() {
        XCTAssertEqual(runWith(feedback: 0.9, silenceThreshold: 0.0001), 6.38, accuracy: 0.01)
    }
}
