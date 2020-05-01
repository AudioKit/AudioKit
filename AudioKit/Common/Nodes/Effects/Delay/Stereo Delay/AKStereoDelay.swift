// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo delay-line with stereo (linked dual mono) and ping-pong modes
///
open class AKStereoDelay: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKStereoDelayAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "sdly")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Time
    public static let timeRange: ClosedRange<Double> = 0.0 ... 2.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Dry/wet mix
    public static let dryWetMixRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Time
    public static let defaultTime: Double = 0.0

    /// Initial value for Feedback
    public static let defaultFeedback: Double = 0.0

    /// Initial default value for Dry/wet mix
    public static let defaultDryWetMix: Double = 0.5

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    open var time: Double = defaultTime {
        willSet {
            let clampedValue = AKStereoDelay.timeRange.clamp(newValue)
            guard time != clampedValue else { return }
            internalAU?.time.value = AUValue(clampedValue)
        }
    }

    /// Feedback amount. Should be a value between 0-1.
    open var feedback: Double = defaultFeedback {
        willSet {
            let clampedValue = AKStereoDelay.feedbackRange.clamp(newValue)
            guard feedback != clampedValue else { return }
            internalAU?.feedback.value = AUValue(clampedValue)
        }
    }

    /// Dry/wet mix. Should be a value between 0-1.
    open var dryWetMix: Double = defaultDryWetMix {
        willSet {
            let clampedValue = AKStereoDelay.dryWetMixRange.clamp(newValue)
            guard dryWetMix != clampedValue else { return }
            internalAU?.dryWetMix.value = AUValue(clampedValue)
        }
    }

    /// Ping-pong mode: true or false (stereo mode)
    open var pingPong: Bool = false {
        willSet {
            guard pingPong != newValue else { return }
            internalAU?.pingPong.value = AUValue(newValue ? 1.0 : 0.0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
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
    public init(
        _ input: AKNode? = nil,
        maximumDelayTime: Double = AKStereoDelay.timeRange.upperBound,
        time: Double = defaultTime,
        feedback: Double = defaultFeedback,
        dryWetMix: Double = defaultDryWetMix,
        pingPong: Bool = false
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.time = time
            self.feedback = feedback
            self.dryWetMix = dryWetMix
            self.pingPong = pingPong
        }
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
}
