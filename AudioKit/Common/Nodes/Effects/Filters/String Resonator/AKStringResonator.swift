// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AKStringResonator passes the input through a network composed of comb,
/// low-pass and all-pass filters, similar to the one used in some versions of
/// the Karplus-Strong algorithm, creating a string resonator effect. The
/// fundamental frequency of the “string” is controlled by the
/// fundamentalFrequency.  This operation can be used to simulate sympathetic
/// resonances to an input signal.
///
open class AKStringResonator: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKStringResonatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "stre")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Fundamental Frequency
    public static let fundamentalFrequencyRange: ClosedRange<Double> = 12.0 ... 10_000.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Fundamental Frequency
    public static let defaultFundamentalFrequency: Double = 100

    /// Initial value for Feedback
    public static let defaultFeedback: Double = 0.95

    /// Fundamental frequency of string.
    open var fundamentalFrequency: Double = defaultFundamentalFrequency {
        willSet {
            let clampedValue = AKStringResonator.fundamentalFrequencyRange.clamp(newValue)
            guard fundamentalFrequency != clampedValue else { return }
            internalAU?.fundamentalFrequency.value = AUValue(clampedValue)
        }
    }

    /// Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    open var feedback: Double = defaultFeedback {
        willSet {
            let clampedValue = AKStringResonator.feedbackRange.clamp(newValue)
            guard feedback != clampedValue else { return }
            internalAU?.feedback.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - fundamentalFrequency: Fundamental frequency of string.
    ///   - feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode? = nil,
        fundamentalFrequency: Double = defaultFundamentalFrequency,
        feedback: Double = defaultFeedback
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.fundamentalFrequency = fundamentalFrequency
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
