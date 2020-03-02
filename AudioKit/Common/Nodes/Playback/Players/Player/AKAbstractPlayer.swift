//
//  AKAutomatedPlayer.swift
//  AudioKit
//
//  Created by Ryan Francesconi on 9/12/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

/// Psuedo abstract base class for players that wish to use AKFader based automation.
open class AKAbstractPlayer: AKNode {
    /// Since AVAudioEngineManualRenderingMode is only available in 10.13, iOS 11+, this enum duplicates it
    public enum RenderingMode {
        case realtime, offline
    }

    // MARK: - Fade struct

    public struct Fade {
        /// So that the Fade struct can be used outside of AKPlayer
        // AKAbstractPlayer.Fade()
        public init() {}

        /// a constant
        public static var minimumGain: Double = 0.0002

        /// the value that the booster should fade to, settable
        public var maximumGain: Double = 1

        public var inTime: Double = 0 {
            willSet {
                if newValue != inTime { needsUpdate = true }
            }
        }

        // TODO:
        public var inRampType: AKSettings.RampType = .linear {
            willSet {
                if newValue != inRampType { needsUpdate = true }
            }
        }

        // TODO:
        public var outRampType: AKSettings.RampType = .linear {
            willSet {
                if newValue != outRampType { needsUpdate = true }
            }
        }

        // if you want to start midway into a fade
        public var inTimeOffset: Double = 0

        // Currently Unused
        public var inStartGain: Double = minimumGain

        public var outTime: Double = 0 {
            willSet {
                if newValue != outTime { needsUpdate = true }
            }
        }

        public var outTimeOffset: Double = 0

        // Currently Unused
        public var outStartGain: Double = 1

        // the needsUpdate flag is used by the buffering scheme
        var needsUpdate: Bool = false
    }

    // MARK: - Loop struct

    public struct Loop {
        /// So that the Loop struct can be used outside of AKPlayer
        public init() {}

        public var start: Double = 0 {
            willSet {
                if newValue != start { needsUpdate = true }
            }
        }

        public var end: Double = 0 {
            willSet {
                if newValue != end { needsUpdate = true }
            }
        }

        var needsUpdate: Bool = false
    }

    // MARK: - public properties

    /// Will return whether the engine is rendering offline or realtime
    public var renderingMode: RenderingMode {
        if #available(iOS 11, macOS 10.13, tvOS 11, *) {
            // AVAudioEngineManualRenderingMode
            if outputNode.engine?.manualRenderingMode == .offline {
                return .offline
            }
        }
        return .realtime
    }

    /// Holds characteristics about the fade options.
    public var fade = Fade()

    /// Holds characteristics about the loop options.
    public var loop = Loop()

    /// The underlying gain booster which controls fades as well. Created on demand.
    @objc public var faderNode: AKFader?

    @available(*, deprecated, renamed: "fadeOutAndStop(with:)")
    @objc public var stopEnvelopeTime: Double = 0 {
        didSet {
            if faderNode == nil {
                createFader()
            }
        }
    }

    /// Amplification Factor, in the range of 0.0002 to ~
    @objc public var gain: Double {
        get {
            return fade.maximumGain
        }

        set {
            if newValue != 1 && faderNode == nil {
                createFader()
            } else if newValue == 1 && faderNode != nil && !isPlaying {
                removeFader()
            }
            // this is the value that the fader will fade to
            fade.maximumGain = newValue

            // this is the current value of the fader, set immediately
            faderNode?.gain = newValue
        }
    }

    private var _startTime: Double = 0

    /// Get or set the start time of the player.
    @objc open var startTime: Double {
        get {
            // return max(0, _startTime)
            return _startTime
        }

        set {
            _startTime = max(0, newValue)
        }
    }

    private var _endTime: Double = 0

    /// Get or set the end time of the player.
    @objc open var endTime: Double {
        get {
            return isLooping ? loop.end : _endTime
        }

        set {
            var newValue = newValue
            if newValue == 0 {
                newValue = duration
            }
            _endTime = min(newValue, duration)
        }
    }

    // MARK: - public flags

    @objc open internal(set) var isPlaying: Bool = false

    @objc open var isLooping: Bool = false

    /// true if any fades have been set
    @objc open var isFaded: Bool {
        return fade.inTime > 0 || fade.outTime > 0
    }

    // MARK: - abstract items, to be implemented in subclasses

    @objc open var duration: Double {
        return 0
    }

    @objc open var sampleRate: Double {
        return AKSettings.sampleRate
    }

    // this can optionally be overridden by subclasses.
    // In the main class for scheduling purposes. See AKDynamicPlayer
    internal var _rate: Double {
        return 1.0
    }

    internal var stopEnvelopeTimer: Timer?

    /// Stub function to be implemented on route changes in subclasses
    open func initialize(restartIfPlaying: Bool = true) {}

    @objc open func play() {}
    @objc open func stop() {}

    // MARK: internal functions to be used by subclasses

    /// This is used to schedule the fade in and out for a region. It uses values from the fade struct.
    internal func scheduleFader(at audioTime: AVAudioTime?, hostTime: UInt64?, frameOffset: AVAudioFramePosition = 512) {
        guard let audioTime = audioTime, let faderNode = faderNode else { return }

        // AKLog(fade, faderNode?.rampDuration, faderNode?.gain, audioTime, hostTime)
        // frameOffset offsets scheduling render cycles in the future in order to put after AUEventSampleTimeImmediate events
        // or for delayed starts

        // reset automation if it is running
        faderNode.stopAutomation()

        let inTimeInSamples: AUEventSampleTime = frameOffset

        var inTime = fade.inTime
        if inTime > 0 {
            let value = fade.maximumGain
            var fadeFrom = Fade.minimumGain

            // starting in the middle of a fade in
            if fade.inTimeOffset > 0 && fade.inTimeOffset < inTime {
                let ratio = fade.inTimeOffset / inTime
                fadeFrom = value * ratio
                inTime -= fade.inTimeOffset

                AKLog("In middle of a fade in... adjusted inTime to \(inTime)")
            } else {
                // set immediately to 0
                faderNode.gain = Fade.minimumGain
            }

            let rampSamples = AUAudioFrameCount(inTime * sampleRate)

            AKLog("Scheduling fade IN to value: \(value) at inTimeInSamples \(inTimeInSamples) rampDuration \(rampSamples) fadeFrom \(fadeFrom) fade.inTimeOffset \(fade.inTimeOffset)")

            // inTimeInSamples
            faderNode.addAutomationPoint(value: fadeFrom,
                                         at: AUEventSampleTimeImmediate,
                                         anchorTime: audioTime.sampleTime,
                                         rampDuration: AUAudioFrameCount(0),
                                         rampType: fade.inRampType)

            // then fade it in
            faderNode.addAutomationPoint(value: value,
                                         at: inTimeInSamples,
                                         anchorTime: audioTime.sampleTime,
                                         rampDuration: rampSamples,
                                         rampType: fade.inRampType)
        }

        var outTime = fade.outTime
        if outTime > 0 {
            // when the start of the fade out should occur
            var timeTillFadeOut = (duration - startTime) - (duration - endTime) - outTime

            // adjust the scheduled fade out based on the playback rate
            if _rate != 1 {
                timeTillFadeOut /= _rate
            }
            var outTimeInSamples = inTimeInSamples + AUEventSampleTime(timeTillFadeOut * sampleRate)
            var outOffset: AUEventSampleTime = 0

            // starting in the middle of a fade out
            if fade.outTimeOffset > 0, fade.outTimeOffset > duration - outTime {
                // just fade now the remainder of the segment
                var newOutTime = duration - startTime
                if endTime < duration {
                    newOutTime -= (duration - endTime)
                }

                AKLog("In middle of a fade out... adjusted outTime to \(newOutTime)")

                outTimeInSamples = 0

                let ratio = newOutTime / outTime
                let fadeFrom = fade.maximumGain * ratio
                faderNode.addAutomationPoint(value: fadeFrom,
                                             at: outTimeInSamples,
                                             anchorTime: audioTime.sampleTime,
                                             rampDuration: AUAudioFrameCount(0),
                                             rampType: fade.inRampType)

                outTime = newOutTime
                outOffset = frameOffset

            } else if inTime == 0 {
                AKLog("reset to \(fade.maximumGain) if there is no fade in or are past it")
                // inTimeInSamples
                faderNode.addAutomationPoint(value: fade.maximumGain,
                                             at: AUEventSampleTimeImmediate,
                                             anchorTime: audioTime.sampleTime,
                                             rampDuration: AUAudioFrameCount(0),
                                             rampType: fade.inRampType)
            }

            // must adjust for _rate
            let fadeLengthInSamples = AUAudioFrameCount((outTime / _rate) * sampleRate)

            let value = Fade.minimumGain

            AKLog("Scheduling fade OUT (\(outTime) sec) to value: \(value) at outTimeInSamples \(outTimeInSamples) fadeLengthInSamples \(fadeLengthInSamples)")
            faderNode.addAutomationPoint(value: value,
                                         at: outTimeInSamples + outOffset,
                                         anchorTime: audioTime.sampleTime,
                                         rampDuration: fadeLengthInSamples,
                                         rampType: fade.outRampType)
        }
    }

    public func createFader() {
        // only do this once when needed
        guard faderNode == nil else { return }

        AKLog("Creating fader")
        faderNode = AKFader()
        faderNode?.gain = gain
        // faderNode?.rampType = rampType

        initialize()
    }

    // Removes the internal fader from the signal chain
    public func removeFader() {
        guard faderNode != nil else { return }
        let wasPlaying = isPlaying
        stop()
        faderNode?.disconnectOutput()
        faderNode?.detach()
        faderNode = nil
        AKLog("Fader was removed")
        initialize()
        if wasPlaying {
            play()
        }
    }

    public func resetFader() {
        faderNode?.gain = fade.maximumGain
    }

    public func fadeOut(with time: Double) {
        faderNode?.stopAutomation()
        let outFrames = AUAudioFrameCount(time * sampleRate)
        faderNode?.addAutomationPoint(value: Fade.minimumGain,
                                      at: AUEventSampleTimeImmediate,
                                      anchorTime: 0,
                                      rampDuration: outFrames,
                                      rampType: fade.outRampType)

        let now = AVAudioTime(hostTime: mach_absolute_time(), sampleTime: 0, atRate: sampleRate)
        faderNode?.startAutomation(at: now, duration: nil)
    }

    open override func detach() {
        super.detach()
        faderNode?.detach()
        faderNode = nil
    }
}
