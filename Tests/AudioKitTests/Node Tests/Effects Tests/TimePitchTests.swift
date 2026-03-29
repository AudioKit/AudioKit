// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import XCTest

/// Tests for TimePitch node (GitHub #2968)
class TimePitchTests: XCTestCase {

    /// Reproduces GitHub #2968: after changing TimePitch rate away from 1.0 and back,
    /// the audio has a "robotic/phasey" artifact compared to audio that was never
    /// rate-shifted.
    ///
    /// Uses ConstantGenerator (position-independent signal) so playback position
    /// differences don't affect comparison. Renders through TimePitch at rate 2.0
    /// to dirty the audio unit's internal overlap-add buffers, then switches back
    /// to rate 1.0 and compares against a clean reference.
    func testRateChangeAndReturnProducesCleanAudio() {
        let renderDuration = 2.0

        // Render 1: Clean reference — rate stays at 1.0 the entire time
        let engine1 = AudioEngine()
        let gen1 = ConstantGenerator(constant: 0.5)
        let timePitch1 = TimePitch(gen1)
        engine1.output = timePitch1

        let cleanAudio = engine1.startTest(totalDuration: renderDuration)
        cleanAudio.append(engine1.render(duration: renderDuration))
        let cleanMD5 = cleanAudio.md5

        XCTAssertFalse(cleanAudio.isSilent, "Clean audio should not be silent")

        // Render 2: Rate changed to 2.0, render 1s to dirty internal buffers,
        // then change back to 1.0 and render the comparison segment
        let engine2 = AudioEngine()
        let gen2 = ConstantGenerator(constant: 0.5)
        let timePitch2 = TimePitch(gen2)
        engine2.output = timePitch2

        let dirtySetup = engine2.startTest(totalDuration: 1.0 + renderDuration)
        timePitch2.rate = 2.0
        dirtySetup.append(engine2.render(duration: 1.0)) // render at rate 2.0

        timePitch2.rate = 1.0
        let afterChangeAudio = engine2.render(duration: renderDuration)
        let afterChangeMD5 = afterChangeAudio.md5

        XCTAssertFalse(afterChangeAudio.isSilent, "Audio after rate change should not be silent")

        // With a constant signal, the output at rate 1.0 should be identical
        // regardless of prior rate changes. If AVAudioUnitTimePitch's internal
        // overlap-add buffers are corrupted, these MD5s will differ.
        XCTAssertEqual(cleanMD5, afterChangeMD5,
                       "Audio at rate 1.0 should be identical whether or not rate was " +
                       "previously changed to 2.0. Clean: \(cleanMD5), " +
                       "after rate change: \(afterChangeMD5)")
    }

    func testDefaultRate() {
        let timePitch = TimePitch(ConstantGenerator(constant: 1))
        XCTAssertEqual(timePitch.rate, 1.0)
        XCTAssertEqual(timePitch.pitch, 0.0)
        XCTAssertEqual(timePitch.overlap, 8.0)
    }

    func testRateClamping() {
        let timePitch = TimePitch(ConstantGenerator(constant: 1))
        timePitch.rate = 100.0
        XCTAssertEqual(timePitch.rate, 32.0)
        timePitch.rate = 0.0
        XCTAssertEqual(timePitch.rate, 0.03125)
    }

    func testPitchClamping() {
        let timePitch = TimePitch(ConstantGenerator(constant: 1))
        timePitch.pitch = 5000.0
        XCTAssertEqual(timePitch.pitch, 2400.0)
        timePitch.pitch = -5000.0
        XCTAssertEqual(timePitch.pitch, -2400.0)
    }
}
