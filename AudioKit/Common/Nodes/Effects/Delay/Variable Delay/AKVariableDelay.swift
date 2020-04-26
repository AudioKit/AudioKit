// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A delay line with cubic interpolation.
///
open class AKVariableDelay: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKVariableDelayAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "vdla")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Time
    public static let timeRange: ClosedRange<Double> = 0 ... 10

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<Double> = 0 ... 1

    /// Initial value for Time
    public static let defaultTime: Double = 0

    /// Initial value for Feedback
    public static let defaultFeedback: Double = 0

    /// Initial value for Maximum Delay Time
    public static let defaultMaximumDelayTime: Double = 5

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    open var time: Double = defaultTime {
        willSet {
            let clampedValue = AKVariableDelay.timeRange.clamp(newValue)
            guard time != clampedValue else { return }
            internalAU?.time.value = AUValue(clampedValue)
        }
    }

    /// Feedback amount. Should be a value between 0-1.
    open var feedback: Double = defaultFeedback {
        willSet {
            let clampedValue = AKVariableDelay.feedbackRange.clamp(newValue)
            guard feedback != clampedValue else { return }
            internalAU?.feedback.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: AKNode? = nil,
        time: Double = defaultTime,
        feedback: Double = defaultFeedback,
        maximumDelayTime: Double = defaultMaximumDelayTime
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
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
