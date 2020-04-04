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
        // a few presets for lack of a better place to put them at the moment
        public static var linearTaper = (in: 1.0, out: 1.0)

        // half pipe
        public static var audioTaper = (in: 3.0, out: 0.3333)

        // flipped half pipe
        public static var reverseAudioTaper = (in: 0.3333, out: 3.0)

        /// An init is requited for the Fade struct to be used outside of AKPlayer
        // AKAbstractPlayer.Fade()
        public init() {}

        /// a constant
        public static var minimumGain: Double = 0 // 0.0002

        /// the value that the fader should fade to, settable
        public var maximumGain: Double = 1

        // In properties
        public var inTime: Double = 0 {
            willSet {
                if newValue != inTime { needsUpdate = true }
            }
        }

        // if you want to start midway into a fade
        // public var inTimeOffset: Double = 0

        public var inTaper: Double = audioTaper.in {
            willSet {
                if newValue != inTaper { needsUpdate = true }
            }
        }

        // the slope adjustment in the taper
        public var inSkew: Double = 0.3333

        // Out properties
        public var outTime: Double = 0 {
            willSet {
                if newValue != outTime { needsUpdate = true }
            }
        }

        public var outTaper: Double = audioTaper.out {
            willSet {
                if newValue != outTaper { needsUpdate = true }
            }
        }

        // the slope adjustment in the taper
        public var outSkew: Double = 1

        // if you want to start midway into a fade
        // public var outTimeOffset: Double = 0

        // the needsUpdate flag is used by the buffering scheme
        var needsUpdate: Bool = false

        // To be removed:
        @available(*, deprecated, message: "Removed in favor of Taper")
        public var inRampType: AKSettings.RampType = .linear
        @available(*, deprecated, message: "Removed in favor of Taper")
        public var outRampType: AKSettings.RampType = .linear
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

    /// The underlying gain booster and main output which controls fades as well.
    @objc public var faderNode: AKFader?

    @available(*, deprecated, renamed: "fadeOutAndStop(with:)")
    @objc public var stopEnvelopeTime: Double = 0 {
        didSet {
            if stopEnvelopeTime > 0 {
                startFader()
            }
        }
    }

    /// Amplification Factor, in the range of 0 to 2
    @objc public var gain: Double {
        get {
            return fade.maximumGain
        }

        set {
            if newValue != 1 {
                startFader()
            } else if newValue == 1 {
                bypassFader()
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

    // offsetTime represents where in the current edited file playback is going to start
    // this is only relevant if the player has fades applied to it to calculate if it's
    // now starting in the middle of a fade in or out point
    @objc open var offsetTime: Double = 0

    // MARK: - public flags

    @objc open internal(set) var isPlaying: Bool = false

    @objc open var isLooping: Bool = false

    /// true if the player has any fades, in or outƒ
    @objc open var isFaded: Bool {
        return fade.inTime > 0 || fade.outTime > 0
    }

    // MARK: - abstract items, to be implemented in subclasses

    @objc open var duration: Double {
        return 0
    }

    internal var editedDuration: Double {
        return (duration - startTime) - (duration - endTime)
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

        // reset automation if it is running
        faderNode.stopAutomation()

        let inTimeInSamples: AUEventSampleTime = frameOffset

        if fade.inTime > 0, offsetTime < fade.inTime {
            // realtime, turn the gain off to be sure it's off before the fade starts
            faderNode.gain = Fade.minimumGain

            let inOffset = AUAudioFrameCount(offsetTime * sampleRate)
            let rampDuration = AUAudioFrameCount(fade.inTime * sampleRate)

//            AKLog("Scheduling fade IN to fade.maximumGain", fade.maximumGain, "rampDuration", rampDuration,
//                  "offsetTime", offsetTime, "taper", fade.inTaper)

            // add this extra point for the case where it is offline processing
            faderNode.addAutomationPoint(value: Fade.minimumGain,
                                         at: 0,
                                         anchorTime: 0,
                                         rampDuration: 0,
                                         taper: fade.inTaper,
                                         skew: fade.inSkew,
                                         offset: 0)

            // then fade it in. fade.maximumGain is the ceiling it should fade to
            faderNode.addAutomationPoint(value: fade.maximumGain,
                                         at: inTimeInSamples,
                                         anchorTime: audioTime.sampleTime,
                                         rampDuration: rampDuration,
                                         taper: fade.inTaper,
                                         skew: fade.inSkew,
                                         offset: inOffset)
        } else {
            // if it's past the fade.inTime that means we should set to the max gain
            faderNode.addAutomationPoint(value: fade.maximumGain,
                                         at: AUEventSampleTimeImmediate,
                                         anchorTime: audioTime.sampleTime,
                                         rampDuration: 0,
                                         taper: fade.inTaper,
                                         skew: fade.inSkew,
                                         offset: 0)
        }

        if fade.outTime > 0 {
            // when the start of the fade out should occur
            var timeTillFadeOut = editedDuration - fade.outTime

            // adjust the scheduled fade out based on the playback rate
            if _rate != 1 {
                timeTillFadeOut /= _rate
            }
            var outTimeInSamples = inTimeInSamples + AUEventSampleTime(timeTillFadeOut * sampleRate)
            var outOffset: AUAudioFrameCount = 0

            // starting in the middle of a fade out
            if offsetTime > 0, timeTillFadeOut < 0 { // duration - fade.outTime
                outOffset = AUAudioFrameCount(abs(timeTillFadeOut) * sampleRate)
                outTimeInSamples = 0
            }

            // must adjust for _rate
            let fadeLengthInSamples = AUAudioFrameCount((fade.outTime / _rate) * sampleRate)

            faderNode.addAutomationPoint(value: Fade.minimumGain,
                                         at: outTimeInSamples,
                                         anchorTime: audioTime.sampleTime,
                                         rampDuration: fadeLengthInSamples,
                                         taper: fade.outTaper,
                                         skew: fade.outSkew,
                                         offset: outOffset)
        }
    }

    func secondsToFrames(_ value: Double) -> AUAudioFrameCount {
        return AUAudioFrameCount(value * sampleRate)
    }

    // Enables the internal fader from the signal chain if it is bypassed
    public func startFader() {
        if faderNode?.isBypassed == true {
            faderNode?.start()
        }
    }

    // Bypasses the internal fader from the signal chain
    public func bypassFader() {
        if faderNode?.isBypassed == false {
            faderNode?.bypass()
        }
    }

    public func resetFader() {
        faderNode?.gain = fade.maximumGain
    }

    public func fadeOut(with time: Double, taper: Double? = nil) {
        faderNode?.stopAutomation()
        let outFrames = AUAudioFrameCount(time * sampleRate)
        faderNode?.addAutomationPoint(value: Fade.minimumGain,
                                      at: AUEventSampleTimeImmediate,
                                      anchorTime: 0,
                                      rampDuration: outFrames,
                                      taper: taper ?? fade.outTaper)

        let now = AVAudioTime(hostTime: mach_absolute_time(), sampleTime: 0, atRate: sampleRate)
        faderNode?.startAutomation(at: now, duration: nil)
    }

    open override func detach() {
        super.detach()
        faderNode?.detach()
        faderNode = nil
    }
}

extension AKAbstractPlayer {
    @available(*, unavailable, renamed: "startFader")
    public func createFader() {}

    @available(*, unavailable, renamed: "bypassFader")
    public func removeFader() {}
}
