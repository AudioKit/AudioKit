import AVFoundation
import XCTest

@testable import AudioKit

class AudioPlayerTests: XCTestCase {

    override func setUp() {
        Settings.sampleRate = 44100
    }

    func testBasic() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 5.0))

        testMD5(audio)
    }

    func testLoop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            XCTFail("Couldn't create buffer")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true
        player.buffer = buffer

        let audio = engine.startTest(totalDuration: 10.0)
        player.play()

        audio.append(engine.render(duration: 10.0))

        testMD5(audio)
    }

    func testPlayAfterPause() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 2.0))
        player.pause()
        audio.append(engine.render(duration: 1.0))
        player.play()
        audio.append(engine.render(duration: 2.0))

        testMD5(audio)
    }

    func testEngineRestart() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)
        player.file = file

        player.play()
        audio.append(engine.render(duration: 2.0))
        player.stop()
        engine.stop()
        _ = engine.startTest(totalDuration: 2.0)
        audio.append(engine.render(duration: 1.0))
        player.play()
        audio.append(engine.render(duration: 2.0))

        testMD5(audio)
    }

    func testScheduleFile() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.play()
        audio.append(engine.render(duration: 5.0))
        engine.stop()

        testMD5(audio)
    }

    func testVolume() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        player.volume = 0.1
        engine.output = player
        player.file = file

        let audio = engine.startTest(totalDuration: 5.0)
        player.play()
        audio.append(engine.render(duration: 5.0))
        testMD5(audio)
    }

    func testSeek() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 4.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 1.0)
        player.play()
        audio.append(engine.render(duration: 4.0))
        testMD5(audio)
    }

    func testCurrentTime() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.seek(time: 0.5)
        player.play()

        audio.append(engine.render(duration: 2.0))

        let currentTime = player.currentTime
        XCTAssertEqual(currentTime, 2.5)

        testMD5(audio)
    }

    func testToggleEditTime() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 1.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }
        player.editStartTime = 0.5
        player.editEndTime = 0.6

        player.play()

        let onStartTime = player.editStartTime
        let onEndTime = player.editEndTime
        XCTAssertEqual(onStartTime, 0.5)
        XCTAssertEqual(onEndTime, 0.6)

        player.isEditTimeEnabled = false

        let offStartTime = player.editStartTime
        let offEndTime = player.editEndTime
        XCTAssertEqual(offStartTime, 0)
        XCTAssertEqual(offEndTime, player.file?.duration)

        player.isEditTimeEnabled = true

        let nextOnStartTime = player.editStartTime
        let nextOnEndTime = player.editEndTime
        XCTAssertEqual(nextOnStartTime, 0.5)
        XCTAssertEqual(nextOnEndTime, 0.6)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testSwitchFilesDuringPlayback() {
        guard let url1 = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        guard let url2 = Bundle.module.url(forResource: "TestResources/chromaticScale-1", withExtension: "aiff") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 3.0)
        do {
            try player.load(url: url1)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()

        do {
            try player.load(url: url2)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        audio.append(engine.render(duration: 3.0))
        testMD5(audio)
    }

    func testCanStopPausedPlayback() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let file = try? AVAudioFile(forReading: url)
        else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 3.0)
        player.file = file

        XCTAssertEqual(player.status, .stopped)
        player.play()
        XCTAssertEqual(player.status, .playing)
        audio.append(engine.render(duration: 2.0))
        player.pause()
        XCTAssertEqual(player.status, .paused)
        audio.append(engine.render(duration: 1.0))
        player.stop()
        XCTAssertEqual(player.status, .stopped)
        testMD5(audio)
    }

    func testCurrentPosition() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }
        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        audio.append(engine.render(duration: 1.0))
        let currentPosition = (player.currentPosition * 100).rounded() / 100
        // player.duration approx = 5.48; 1.0 / 5.48 = 0.18 to 2d.p.
        XCTAssertEqual(currentPosition, 0.18)
        testMD5(audio)
    }

    func testSeekAfterPause() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        player.seek(time: 1.0)
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(player.status, .playing)

        player.pause()
        XCTAssertEqual(player.status, .paused)

        player.play()
        player.seek(time: 1.0)
        audio.append(engine.render(duration: 1.0))
        let currentTime = player.currentTime
        XCTAssertEqual(currentTime, 4.0)
        testMD5(audio)
    }

    func testSeekAfterStop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        audio.append(engine.render(duration: 1.0))
        let currentTime1 = player.currentTime
        XCTAssertEqual(currentTime1, 1.0)

        player.stop()
        let currentTime2 = player.currentTime
        XCTAssertEqual(currentTime2, 0.0)

        player.play()
        player.seek(time: 0.5)
        audio.append(engine.render(duration: 1.0))
        let currentTime3 = player.currentTime
        XCTAssertEqual(currentTime3, 1.5)
        testMD5(audio)
    }

    func testSeekWhileStoppedPreservesStoppedState() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 2.0)

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        XCTAssertEqual(player.status, .stopped)
        player.seek(time: 1.0)
        XCTAssertEqual(player.status, .stopped)
        XCTAssertEqual(player.currentTime, 1.0, accuracy: 0.001)

        player.play()
        audio.append(engine.render(duration: 1.0))

        XCTAssertEqual(player.status, .playing)
        XCTAssertEqual(player.currentTime, 2.0, accuracy: 0.001)
    }

    func testSeekWhilePausedPreservesPausedState() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 3.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        audio.append(engine.render(duration: 1.0))
        player.pause()

        XCTAssertEqual(player.status, .paused)
        XCTAssertEqual(player.currentTime, 1.0, accuracy: 0.001)

        player.seek(time: 1.0)

        XCTAssertEqual(player.status, .paused)
        XCTAssertEqual(player.currentTime, 2.0, accuracy: 0.001)

        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(player.currentTime, 2.0, accuracy: 0.001)

        player.play()
        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(player.status, .playing)
        XCTAssertEqual(player.currentTime, 3.0, accuracy: 0.001)
    }

    func testSeekWhilePausedDoesNotTriggerCompletionHandler() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 6.0)
        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        audio.append(engine.render(duration: 1.0))
        player.pause()
        player.seek(time: 3.5)

        XCTAssertEqual(player.status, .paused)
        XCTAssertEqual(player.currentTime, 4.5, accuracy: 0.001)
        XCTAssertEqual(completionCount, 0)

        audio.append(engine.render(duration: 1.0))
        XCTAssertEqual(completionCount, 0)
    }

    func testSeekForwardsAndBackwards() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 4.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        player.seek(time: 1.0)
        audio.append(engine.render(duration: 2.0))
        let currentTime1 = player.currentTime
        XCTAssertEqual(currentTime1, 3)

        player.seek(time: -1.0)
        player.seek(time: -1.0)
        XCTAssert(player.status == .playing)

        audio.append(engine.render(duration: 1.0))
        let currentTime2 = player.currentTime
        XCTAssertEqual(currentTime2, 2)
        testMD5(audio)
    }

    /// Regression test for the stale-completion race introduced by PR #2978.
    /// A completion from an older scheduled segment must not affect the newer
    /// playback that replaced it after seek/reschedule.
    func testStaleCompletionDoesNotStompPlaybackOrInvokeHandler() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = false

        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        let staleGeneration = player.bumpScheduleGeneration()

        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertEqual(player.status, .playing)

        let staleCompletionIgnored = expectation(description: "stale completion ignored")
        DispatchQueue.global().async {
            player.invokeCompletionHandlerOnMain(generation: staleGeneration)
            DispatchQueue.main.async {
                staleCompletionIgnored.fulfill()
            }
        }
        wait(for: [staleCompletionIgnored], timeout: 1.0)

        XCTAssertEqual(player.status, .playing,
                       "stale completion must not stomp status to .stopped")
        XCTAssertEqual(completionCount, 0,
                       "stale completion must not invoke the user-supplied handler")
    }

    /// `stop()` promises not to generate a callback event, even if the retired
    /// schedule later reports completion.
    func testStopDoesNotInvokeCompletionHandler() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = false

        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 0.1))
        let stoppedGeneration = player.currentScheduleGeneration
        player.stop()

        player.internalCompletionHandler(generation: stoppedGeneration)

        XCTAssertEqual(player.status, .stopped)
        XCTAssertEqual(completionCount, 0,
                       "stop() must not produce a user completion callback")
    }

    /// Regression: seeking while playing must not report end-of-file. On a device, `playerNode.stop()`
    /// can fire the outgoing segment's `.dataPlayedBack` completion before seek reschedules. Offline
    /// rendering doesn't reproduce that, so the hook injects the completion at the stop boundary.
    func testSeekWhilePlayingDoesNotInvokeCompletionHandler() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = false

        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertEqual(player.status, .playing)

        // The playing segment's generation; its stop-completion is what fires during seek.
        let retiredGeneration = player.currentScheduleGeneration
        var hookCallCount = 0
        player.seekPreStopTestHook = {
            hookCallCount += 1
            // Assert both pre-stop guards here: internalCompletionHandler checks the generation before
            // isSeeking, so the completion count alone wouldn't prove isSeeking was set in time.
            XCTAssertNotEqual(player.currentScheduleGeneration, retiredGeneration,
                              "seek must retire the outgoing generation before stopping the node")
            XCTAssertTrue(player.isSeeking,
                          "seek must mark isSeeking before stopping the node")
            // Stand in for AVAudioPlayerNode delivering the retired segment's completion on stop.
            player.internalCompletionHandler(generation: retiredGeneration)
        }

        player.seek(time: 0.5)
        player.seekPreStopTestHook = nil

        XCTAssertEqual(hookCallCount, 1, "the pre-stop hook must fire exactly once per seek")
        XCTAssertEqual(completionCount, 0,
                       "a seek while playing must not invoke the user completion handler")
        XCTAssertEqual(player.status, .playing,
                       "a seek while playing must keep the player playing")

        // The same retired completion arriving after seek() returns (isSeeking is false again)
        // must still be rejected by generation identity.
        player.internalCompletionHandler(generation: retiredGeneration)

        XCTAssertEqual(completionCount, 0,
                       "a late-arriving retired completion must not invoke the user completion handler")
        XCTAssertEqual(player.status, .playing,
                       "a late-arriving retired completion must not stop the player")
    }

    /// Buffered variant of `testSeekWhilePlayingDoesNotInvokeCompletionHandler`: the reschedule goes
    /// through `scheduleBuffer` rather than `scheduleSegment`, a separate completion path. The injected
    /// stop-completion must still be suppressed.
    func testSeekWhilePlayingBufferedDoesNotInvokeCompletionHandler() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = false

        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertEqual(player.status, .playing)

        let retiredGeneration = player.currentScheduleGeneration
        var hookCallCount = 0
        player.seekPreStopTestHook = {
            hookCallCount += 1
            XCTAssertNotEqual(player.currentScheduleGeneration, retiredGeneration,
                              "buffered seek must retire the outgoing generation before stopping the node")
            XCTAssertTrue(player.isSeeking,
                          "buffered seek must mark isSeeking before stopping the node")
            player.internalCompletionHandler(generation: retiredGeneration)
        }

        player.seek(time: 0.5)
        player.seekPreStopTestHook = nil

        XCTAssertEqual(hookCallCount, 1, "the pre-stop hook must fire exactly once per seek")
        XCTAssertEqual(completionCount, 0,
                       "a buffered seek while playing must not invoke the user completion handler")
        XCTAssertEqual(player.status, .playing,
                       "a buffered seek while playing must keep the player playing")
    }

    /// Buffered + looping seek: an injected stop-completion must still be suppressed. This doesn't test
    /// natural loop callbacks (seamless buffered looping emits none) — only that the retired stop
    /// completion during seek is ignored.
    func testSeekWhileLoopingBufferedDoesNotInvokeSpuriousCompletion() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true

        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url, buffered: true)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertEqual(player.status, .playing)

        let retiredGeneration = player.currentScheduleGeneration
        var hookCallCount = 0
        player.seekPreStopTestHook = {
            hookCallCount += 1
            XCTAssertNotEqual(player.currentScheduleGeneration, retiredGeneration,
                              "looping buffered seek must retire the outgoing generation before stopping the node")
            XCTAssertTrue(player.isSeeking,
                          "looping buffered seek must mark isSeeking before stopping the node")
            player.internalCompletionHandler(generation: retiredGeneration)
        }

        player.seek(time: 0.5)
        player.seekPreStopTestHook = nil

        XCTAssertEqual(hookCallCount, 1, "the pre-stop hook must fire exactly once per seek")
        XCTAssertEqual(completionCount, 0,
                       "a looping buffered seek must not invoke a spurious completion")
        XCTAssertEqual(player.status, .playing,
                       "a looping buffered seek must keep the player playing")
    }

    /// A completion for the current generation is a real end-of-file: it must call the user handler
    /// once and stop a non-looping player — including for the segment scheduled by a seek, so the
    /// pre-stop generation bump can't starve legitimate completions. Driven directly (like
    /// `testStopDoesNotInvokeCompletionHandler`) because offline rendering doesn't reproduce the
    /// `.dataPlayedBack` callback.
    func testCurrentGenerationCompletionStillInvokesHandler() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = false

        var completionCount = 0
        player.completionHandler = {
            completionCount += 1
        }

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        let audio = engine.startTest(totalDuration: 1.0)
        player.play()
        audio.append(engine.render(duration: 0.1))
        XCTAssertEqual(player.status, .playing)

        player.seek(time: 0.5)
        XCTAssertEqual(player.status, .playing, "the player must still be playing after the seek")

        // The segment scheduled by the seek reaching its natural end-of-file.
        player.internalCompletionHandler(generation: player.currentScheduleGeneration)

        XCTAssertEqual(completionCount, 1,
                       "a completion for the current generation must invoke the handler exactly once")
        XCTAssertEqual(player.status, .stopped,
                       "a non-looping player must be .stopped after its current segment completes")
    }

    func testSeekWillStop() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player

        let audio = engine.startTest(totalDuration: 5.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        player.seek(time: 6.0)  // player.duration < 5.5
        audio.append(engine.render(duration: 1.0))
        XCTAssert(player.status == .stopped)

        player.play()
        audio.append(engine.render(duration: 1.0))
        XCTAssert(player.status == .playing)

        player.seek(time: -2.0)  // currentTime == 1.0
        audio.append(engine.render(duration: 1.0))
        XCTAssert(player.status == .stopped)
        testMD5(audio)
    }

    func testSeekWillContinueLooping() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav") else {
            XCTFail("Didn't get test file")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = true

        let audio = engine.startTest(totalDuration: 4.0)

        do {
            try player.load(url: url)
        } catch let error as NSError {
            Log(error, type: .error)
            XCTFail(error.description)
        }

        player.play()
        XCTAssert(player.status == .playing)

        player.seek(time: 6) // player.duration < 5.5
        audio.append(engine.render(duration: 2.0))
        XCTAssert(player.status == .playing)
        testMD5(audio)
    }

    func testPlaybackWillStopWhenSettingLoopingForBuffer() {
        guard let url = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let buffer = try? AVAudioPCMBuffer(url: url)
        else {
            XCTFail("Couldn't create buffer")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.buffer = buffer
        player.isLooping = false

        let audio = engine.startTest(totalDuration: 4.0)
        player.play()

        player.play()
        audio.append(engine.render(duration: 2.0))
        XCTAssert(player.status == .playing)

        player.isLooping = false
        audio.append(engine.render(duration: 2.0))
        XCTAssert(player.status == .stopped)
        testMD5(audio)
    }

    // https://github.com/AudioKit/AudioKit/issues/2971
    // Verifies that play() restarts after non-looping playback completes.
    // The completion handler resets status to .stopped so subsequent
    // play() calls are not silently ignored.
    func testPlayAfterNonLoopingCompletion() {
        guard let counting = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav"),
              let drumLoop = Bundle.module.url(forResource: "TestResources/drumloop", withExtension: "wav")
        else {
            XCTFail("Couldn't find files")
            return
        }

        let engine = AudioEngine()
        let player = AudioPlayer()
        engine.output = player
        player.isLooping = false

        // Use the completion handler to load a new file and play it.
        // Before the fix in #2971, play() inside the completion handler
        // was silently ignored because status remained .playing.
        player.completionHandler = {
            try? player.load(url: drumLoop)
            player.play()
        }

        try? player.load(url: counting)
        let audio = engine.startTest(totalDuration: 9.0)
        player.play()
        audio.append(engine.render(duration: 9.0))

        // The MD5 proves the drumloop played after counting finished,
        // confirming play() works after non-looping completion.
        testMD5(audio)
    }

    // https://github.com/AudioKit/AudioKit/issues/2916
    func testCompletionHandler() {
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
        engine.output = player
        player.completionHandler = {
            try? player.load(url: drumLoop)
            player.play()
        }
        try? player.load(url: counting)
        let audio = engine.startTest(totalDuration: 9.0)
        player.play()
        audio.append(engine.render(duration: 9.0))
        testMD5(audio)
    }
}
