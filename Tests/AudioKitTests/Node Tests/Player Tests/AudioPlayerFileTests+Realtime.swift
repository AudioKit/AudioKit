import AudioKit
import AVFoundation
import XCTest

// Real time development tests
// These simulate a user interacting with the player via an UI
// These are organized like this so they're easy to bypass for CI tests
extension AudioPlayerFileTests {
    func testFindResources() {
        guard realtimeEnabled else { return }
        XCTAssertNotNil(countingURL != nil)
    }

    func testPause() {
        guard realtimeEnabled else { return }
        realtimeTestPause()
    }

    func testScheduled() {
        guard realtimeEnabled else { return }
        realtimeScheduleFile()
    }

    func testFileLooping() {
        guard realtimeEnabled else { return }
        realtimeLoop(buffered: false, duration: 5)
    }

    func testBufferLooping() {
        guard realtimeEnabled else { return }
        realtimeLoop(buffered: true, duration: 1)
    }

    func testInterrupts() {
        guard realtimeEnabled else { return }
        realtimeInterrupts()
    }

    func testFileEdits() {
        guard realtimeEnabled else { return }
        realtimeTestEdited(buffered: false)
    }

    func testBufferedEdits() {
        guard realtimeEnabled else { return }
        realtimeTestEdited(buffered: true)
    }

    func testMixedSampleRates() {
        guard realtimeEnabled else { return }
        realtimeTestMixedSampleRates(buffered: true)
    }

    func testBufferedMixedSampleRates() {
        guard realtimeEnabled else { return }
        realtimeTestMixedSampleRates(buffered: true)
    }

    // testSeek and testSeekBuffered should effectively sound the same
    func testSeek() {
        guard realtimeEnabled else { return }
        realtimeTestSeek(buffered: false)
    }

    func testSeekBuffered() {
        guard realtimeEnabled else { return }
        realtimeTestSeek(buffered: true)
    }

    func testReversed() {
        guard realtimeEnabled else { return }
        realtimeTestReversed(from: 1, to: 3)
    }

    func testPlayerStatus() {
        guard realtimeEnabled else { return }
        realtimeTestPlayerStatus()
    }

    func testCompletionHandler() {
        //guard realtimeEnabled else { return }
        guard let counting = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav")
        else {
            XCTFail("Couldn't find file")
            return
        }
        guard let drumLoop = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")
        else {
            XCTFail("Couldn't find file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        let firstFileExpectation = XCTestExpectation(description: "Wait for first file completion")
        let secondFileExpectation = XCTestExpectation(description: "Wait for second file completion")
        
        engine.output = player
        player.completionHandler = {
            try? player.load(url: drumLoop)
            player.play(from: 0.0)
            firstFileExpectation.fulfill()
            
            // Set up completion handler for second file
            player.completionHandler = {
                secondFileExpectation.fulfill()
            }
        }
        try? player.load(url: counting)
        try? engine.start()
        player.play()
        
        wait(for: [firstFileExpectation, secondFileExpectation], timeout: 15.0)
        engine.stop()
    }
}
