//
//  AKStereoDelay.swift
//  AudioKit
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
///
open class AKStereoDelay: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKStereoDelayAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "sdly")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var timeParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?
    fileprivate var dryWetMixParameter: AUParameter?
    fileprivate var pingPongParameter: AUParameter?

    /// Lower and upper bounds for Time
    public static let timeRange = 0.0 ... 2.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange = 0.0 ... 1.0

    /// Lower and upper bounds for Dry/wet mix
    public static let dryWetMixRange = 0.0 ... 1.0

    /// Initial value for Time
    public static let defaultTime = 0.0

    /// Initial value for Feedback
    public static let defaultFeedback = 0.0

    /// Initial default value for Dry/wet mix
    public static let defaultDryWetMix = 0.5

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @objc open dynamic var time: Double = defaultTime {
        willSet {
            guard time != newValue else { return }
            if internalAU?.isSetUp == true {
                timeParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.time, value: newValue)
        }
    }

    /// Feedback amount. Should be a value between 0-1.
    @objc open dynamic var feedback: Double = defaultFeedback {
        willSet {
            guard feedback != newValue else { return }
            if internalAU?.isSetUp == true {
                feedbackParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.feedback, value: newValue)
        }
    }

    /// Dry/wet mix. Should be a value between 0-1.
    @objc open dynamic var dryWetMix: Double = defaultDryWetMix {
        willSet {
            guard dryWetMix != newValue else { return }
            if internalAU?.isSetUp == true {
                dryWetMixParameter?.value = AUValue(newValue)
                return
            }

            internalAU?.setParameterImmediately(.dryWetMix, value: newValue)
        }
    }

    /// Ping-pong mode: true or false (stereo mode)
    @objc open dynamic var pingPong: Bool = false {
        willSet {
            guard pingPong != newValue else { return }
            if internalAU?.isSetUp == true {
                pingPongParameter?.value = Float(newValue ? 1.0 : 0.0)
                return
            }
            internalAU?.setParameterImmediately(.pingPong, value: newValue ? 1.0 : 0.0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - dryWetMix: Dry/wet mix. Should be a value between 0-1.
    ///   - pingPong: true for ping-pong mode, false for stereo mode.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        maximumDelayTime: Double = AKStereoDelay.timeRange.upperBound,
        time: Double = defaultTime,
        feedback: Double = defaultFeedback,
        dryWetMix: Double = defaultDryWetMix,
        pingPong: Bool = false
        ) {

        self.time = time
        self.feedback = feedback
        self.dryWetMix = dryWetMix
        self.pingPong = pingPong

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        timeParameter = tree["time"]
        feedbackParameter = tree["feedback"]
        dryWetMixParameter = tree["dryWetMix"]
        pingPongParameter = tree["pingPong"]

        internalAU?.setParameterImmediately(.time, value: time)
        internalAU?.setParameterImmediately(.feedback, value: feedback)
        internalAU?.setParameterImmediately(.dryWetMix, value: dryWetMix)
        internalAU?.setParameterImmediately(.pingPong, value: pingPong ? 1.0 : 0.0)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }

    @objc open func clear() {
        internalAU?.clear()
    }
}
