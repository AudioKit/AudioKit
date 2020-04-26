// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Shane's Chorus
///
open class AKChorus: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKChorusAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0.1 ... 10.0

    /// Lower and upper bounds for Depth
    public static let depthRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<Double> = 0.0 ... 0.25

    /// Lower and upper bounds for Dry Wet Mix
    public static let dryWetMixRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 1.0

    /// Initial value for Depth
    public static let defaultDepth: Double = 0.0

    /// Initial value for Feedback
    public static let defaultFeedback: Double = 0.0

    /// Initial value for Dry Wet Mix
    public static let defaultDryWetMix: Double = 0.0

    /// Frequency. (in Hertz)
    open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKChorus.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Depth
    open var depth: Double = defaultDepth {
        willSet {
            let clampedValue = AKChorus.depthRange.clamp(newValue)
            guard depth != clampedValue else { return }
            internalAU?.depth.value = AUValue(clampedValue)
        }
    }

    /// Feedback
    open var feedback: Double = defaultFeedback {
        willSet {
            let clampedValue = AKChorus.feedbackRange.clamp(newValue)
            guard feedback != clampedValue else { return }
            internalAU?.feedback.value = AUValue(clampedValue)
        }
    }

    /// Dry Wet Mix
    open var dryWetMix: Double = defaultDryWetMix {
        willSet {
            let clampedValue = AKChorus.dryWetMixRange.clamp(newValue)
            guard dryWetMix != clampedValue else { return }
            internalAU?.dryWetMix.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this chorus node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency. (in Hertz)
    ///   - depth: Depth
    ///   - feedback: Feedback
    ///   - dryWetMix: Dry Wet Mix
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: Double = defaultFrequency,
        depth: Double = defaultDepth,
        feedback: Double = defaultFeedback,
        dryWetMix: Double = defaultDryWetMix
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.frequency = frequency
            self.depth = depth
            self.feedback = feedback
            self.dryWetMix = dryWetMix
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
