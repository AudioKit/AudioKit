// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AudioKitEX
import AVFoundation
import CAudioKitEX
import XCTest

class FaderAutomationTests: XCTestCase {
    // Bypass tests for automated CI
    var realtimeEnabled = false
    
    private struct FaderTestNodes {
        var engine: AudioEngine
        var player: AudioPlayer
        var fader: Fader
    }

    private func setupFaderTest(filename: String = "12345") -> FaderTestNodes? {
        guard realtimeEnabled else {
            return nil
        }

        guard let url = Bundle.module.url(forResource: filename,
                                          withExtension: "wav",
                                          subdirectory: "TestResources"),
            let player = AudioPlayer(url: url) else {
            return nil
        }
        let engine = AudioEngine()
        let fader = Fader(player)
        // engine.output will connect the graph
        engine.output = fader
        try? engine.start()
        fader.start()

        // return engine as well so it isn't collected
        return FaderTestNodes(engine: engine, player: player, fader: fader)
    }

    /// Linear fade in now
    func testRealtimeLinearRamp() {
        guard let nodes = setupFaderTest() else {
            return
        }
        let duration = Float(nodes.player.duration)
        nodes.player.play()
        nodes.fader.rampGain(from: 0, to: 1, duration: duration, tapered: false)
        wait(for: nodes.player.duration + 0.5)
    }

    /// Tapered fade in now
    func testRealtimeTaperedRamp() {
        guard let nodes = setupFaderTest() else {
            return
        }
        let duration = Float(nodes.player.duration)
        nodes.player.play()
        nodes.fader.rampGain(from: 0, to: 1, duration: duration, tapered: true)
        wait(for: nodes.player.duration + 0.5)
    }

    /// Play and fade in in the future
    func testRealtimeScheduleTaperedRamp() {
        guard let nodes = setupFaderTest() else {
            return
        }
        let duration = Float(nodes.player.duration)

        // schedule time in seconds
        let delay: TimeInterval = 3

        let scheduledTime = AVAudioTime(hostTime: mach_absolute_time()).offset(seconds: delay)
        nodes.fader.rampGain(from: 0, to: 1, duration: duration, tapered: true, startTime: scheduledTime)
        nodes.player.play(at: scheduledTime)

        Log("Start scheduled play at", scheduledTime)

        wait(for: nodes.player.duration + delay)
    }

    func testRealtimeLongerAutomation() {
        guard let nodes = setupFaderTest(filename: "PinkNoise") else {
            // didn't want to add this file, so it'll just fail here if not in TestResources.
            // 12345 isn't as good for testing ramping
            return
        }
        let duration = nodes.player.duration
        nodes.fader.automateGain(events: upAndDownEvents(duration: duration))
        nodes.player.play()

        wait(for: nodes.player.duration)
    }

    // make some waves...
    private func upAndDownEvents(duration: TimeInterval) -> [AutomationEvent] {
        var curvePoints = [ParameterAutomationPoint]()
        var time: Float = 0
        let rampTaper: Float = 3
        let rampSkew: Float = 0.333
        var targetValue: AUValue = 1

        while time < Float(duration) && targetValue > 0 {
            curvePoints += [
                ParameterAutomationPoint(targetValue: targetValue,
                                         startTime: time + 0.02,
                                         rampDuration: 0.2,
                                         rampTaper: rampTaper,
                                         rampSkew: rampSkew),

                ParameterAutomationPoint(targetValue: 0,
                                         startTime: time + 1,
                                         rampDuration: 0.5,
                                         rampTaper: 1 / rampTaper,
                                         rampSkew: 1 / rampSkew),
            ]

            time += 1
            targetValue -= 0.1
        }

        let curve = AutomationCurve(points: curvePoints)
        let events = curve.evaluate(initialValue: 0,
                                    resolution: 0.01)

        return events
    }

    // for waiting in the background for realtime testing
    private func wait(for interval: TimeInterval) {
        let delayExpectation = XCTestExpectation(description: "delayExpectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: interval + 1)
    }
}
