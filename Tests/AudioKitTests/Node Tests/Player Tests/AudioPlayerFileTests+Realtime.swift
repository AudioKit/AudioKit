import AudioKit
import AVFoundation
import CAudioKit
import XCTest

// Real time development tests
// These simulate a user interacting with the player via an UI

// Thse are organized like this so they're easy to bypass for CI tests
extension AudioPlayerFileTests {
    func testFindResources() {
        guard realtimeTestsEnabled else { return }
        XCTAssertNotNil(countingURL != nil)
    }

    func testPause() {
        guard realtimeTestsEnabled else { return }
        realtimeTestPause()
    }

    func testScheduled() {
        guard realtimeTestsEnabled else { return }
        realtimeScheduleFile()
    }

    func testFileLooping() {
        guard realtimeTestsEnabled else { return }
        realtimeLoop(buffered: false, duration: 2)
    }

    func testBufferLooping() {
        guard realtimeTestsEnabled else { return }
        realtimeLoop(buffered: true, duration: 1)
    }

    func testInterrupts() {
        guard realtimeTestsEnabled else { return }
        realtimeInterrupts()
    }

    func testFileEdits() {
        guard realtimeTestsEnabled else { return }
        realtimeTestEdited(buffered: false)
    }

    func testBufferedEdits() {
        guard realtimeTestsEnabled else { return }
        realtimeTestEdited(buffered: true)
    }

    func testReversed() {
        guard realtimeTestsEnabled else { return }
        realtimeTestReversed(from: 1, to: 3)
    }

    func testSeek() {
        guard realtimeTestsEnabled else { return }
        realtimeTestSeek(buffered: false)
    }

    func testSeekBuffered() {
        guard realtimeTestsEnabled else { return }
        realtimeTestSeek(buffered: true)
    }
}
