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
    public func ramp(from start: AUValue, to target: AUValue, duration: Float) {
        ramp(to: start, duration: 0.02, delay: 0)
        ramp(to: target, duration: duration, delay: 0.02)
    }
}
