// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import AVFoundation
import CAudioKitEX

// TODO: need unit tests (were moved to SoundpipeAudioKit)

/// Automation functions rely on CAudioKit, so they are in this extension in case we want to
/// make a pure-swift AudioKit.
extension NodeParameter {
    /// the `lastRenderTime` of the avAudioNode or a zero sampleTime AVAudioTime
    private var lastRenderTime: AVAudioTime {
        var value = avAudioNode.lastRenderTime ??
            AVAudioTime(sampleTime: 0, atRate: Settings.sampleRate)

        if !value.isSampleTimeValid {
            // if we're rendering, take the sample time from the engine
            if let engine = avAudioNode.engine, engine.isInManualRenderingMode {
                value = AVAudioTime(sampleTime: engine.manualRenderingSampleTime,
                                    atRate: Settings.sampleRate)
            } else {
                // otherwise, a zero sampleTime
                value = AVAudioTime(sampleTime: 0, atRate: Settings.sampleRate)
            }
        }
        return value
    }

    /// Send an automation list to the parameter with an optional offset into the list's timeline.
    ///
    /// The offset in seconds is convenient if you have a set of fixed points but are playing
    /// from somewhere in the middle of them.
    /// - Parameters:
    ///   - events: An array of events
    ///   - offset: A time offset into the events
    public func automate(events: [AutomationEvent], offset: TimeInterval, startTime: AVAudioTime? = nil) {
        guard let engine = avAudioNode.engine else {
            assertionFailure("Engine state isn't ready")
            return
        }

        guard var lastTime = startTime ?? avAudioNode.lastRenderTime else {
            assertionFailure("No starting timestamp")
            return
        }

        // In manual rendering, we may not have a valid lastRenderTime, so
        // assume no rendering has yet occurred and start at 0
        if !lastTime.isSampleTimeValid || engine.isInManualRenderingMode {
            lastTime = AVAudioTime(sampleTime: 0,
                                   atRate: Settings.sampleRate)
        }

        assert(lastTime.isSampleTimeValid)

        if offset != 0 {
            lastTime = lastTime.offset(seconds: -offset)
        }

        automate(events: events, startTime: lastTime)
    }

    /// Begin automation of the parameter.
    ///
    /// If `startTime` is nil, the automation will be scheduled as soon as possible.
    ///
    /// - Parameter events: automation curve
    /// - Parameter startTime: optional time to start automation
    public func automate(events: [AutomationEvent], startTime: AVAudioTime? = nil) {
        guard let engine = avAudioNode.engine else {
            assertionFailure("Engine is nil")
            return
        }

        var startTime = startTime ?? lastRenderTime

        // Don't do this if we're rendering
        if !engine.isInManualRenderingMode,
           startTime.isHostTimeValid && !startTime.isSampleTimeValid {
            // Convert a hostTime based AVAudioTime to sampleTime which is needed
            // for automation to work
            let startTimeSeconds = AVAudioTime.seconds(forHostTime: startTime.hostTime)
            let lastTimeSeconds = AVAudioTime.seconds(forHostTime: lastRenderTime.hostTime)
            let offsetSeconds = startTimeSeconds - lastTimeSeconds

            startTime = lastRenderTime.offset(seconds: offsetSeconds)
        }

        // this must be valid
        assert(startTime.isSampleTimeValid)

        stopAutomation()

        events.withUnsafeBufferPointer { automationPtr in
            guard let automationBaseAddress = automationPtr.baseAddress else { return }

            guard let observer = ParameterAutomationGetRenderObserver(parameter.address,
                                                                      avAudioNode.auAudioUnit.scheduleParameterBlock,
                                                                      Float(Settings.sampleRate),
                                                                      Float(startTime.sampleTime),
                                                                      automationBaseAddress,
                                                                      events.count) else { return }

            renderObserverToken = avAudioNode.auAudioUnit.token(byAddingRenderObserver: observer)
        }
    }

    /// Stop automation
    public func stopAutomation() {
        if let token = renderObserverToken {
            avAudioNode.auAudioUnit.removeRenderObserver(token)
        }
    }

    /// Ramp from a source value (which is ramped to over 20ms) to a target value
    ///
    /// - Parameters:
    ///   - start: initial value
    ///   - target: destination value
    ///   - duration: duration to ramp to the target value in seconds
    public func ramp(from start: AUValue, to target: AUValue, duration: AUValue, startTime scheduledTime: AVAudioTime? = nil) {
        let startTime: AUValue = 0.02

        // without the initial value set here it can miss the AUEventSampleTimeImmediate
        let events = [
            AutomationEvent(targetValue: start, startTime: 0, rampDuration: 0),
            AutomationEvent(targetValue: start, startTime: startTime + 0.01, rampDuration: 0.01),
            AutomationEvent(targetValue: target, startTime: startTime + 0.02, rampDuration: duration)
        ]
        automate(events: events, startTime: scheduledTime)
    }

    /// Tapered Ramp from a source value to a target value
    ///
    /// - Parameters:
    ///   - start: initial value
    ///   - target: destination value
    ///   - duration: duration to ramp to the target value in seconds
    ///   - rampTaper: Taper, default is 3 for fade in, 1/3 for fade out
    ///   - rampSkew: Skew, default is 1/3 for fade in, and 3 for fade out
    ///   - resolution: Segment duration, default 20ms
    public func taperedRamp(from start: AUValue,
                            to target: AUValue,
                            duration: AUValue,
                            rampTaper: AUValue = 3,
                            rampSkew: AUValue = 0.333,
                            resolution: AUValue = 0.02,
                            startTime scheduledTime: AVAudioTime? = nil) {
        stopAutomation()

        let startTime: AUValue = 0.02
        var rampTaper = rampTaper
        var rampSkew = rampSkew

        if target < start {
            rampTaper = 1 / rampTaper
            rampSkew = 1 / rampSkew
        }

        // Somewhat of a hack, but...
        // this insures we get a AUEventSampleTimeImmediate set to the start value
        let setupEvents = [
            AutomationEvent(targetValue: start, startTime: 0, rampDuration: 0),
            AutomationEvent(targetValue: start, startTime: startTime + 0.01, rampDuration: 0.01)
        ]

        let points = [
            ParameterAutomationPoint(targetValue: start,
                                     startTime: startTime + 0.02,
                                     rampDuration: 0.02,
                                     rampTaper: rampTaper,
                                     rampSkew: rampSkew),

            ParameterAutomationPoint(targetValue: target,
                                     startTime: startTime + 0.04,
                                     rampDuration: duration - 0.04,
                                     rampTaper: rampTaper,
                                     rampSkew: rampSkew)
        ]
        let curve = AutomationCurve(points: points)
        let events = setupEvents + curve.evaluate(initialValue: start,
                                                  resolution: resolution)

        automate(events: events, startTime: scheduledTime)
    }
}
