// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// AKStringResonator passes the input through a network composed of comb,
/// low-pass and all-pass filters, similar to the one used in some versions of
/// the Karplus-Strong algorithm, creating a string resonator effect. The
/// fundamental frequency of the “string” is controlled by the
/// fundamentalFrequency.  This operation can be used to simulate sympathetic
/// resonances to an input signal.
///
open class AKStringResonator: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "stre")

    public typealias AKAudioUnitType = AKStringResonatorAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Fundamental Frequency
    public static let fundamentalFrequencyRange: ClosedRange<AUValue> = 12.0 ... 10_000.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Fundamental Frequency
    public static let defaultFundamentalFrequency: AUValue = 100

    /// Initial value for Feedback
    public static let defaultFeedback: AUValue = 0.95

    /// Fundamental frequency of string.
    public let fundamentalFrequency = AKNodeParameter(identifier: "fundamentalFrequency")

    /// Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance.
    /// Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    public let feedback = AKNodeParameter(identifier: "feedback")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - fundamentalFrequency: Fundamental frequency of string.
    ///   - feedback: Feedback amount (value between 0-1).
    ///   A value close to 1 creates a slower decay and a more pronounced resonance.
    ///   Small values may leave input signal unaffected. Depending on the filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode? = nil,
        fundamentalFrequency: AUValue = defaultFundamentalFrequency,
        feedback: AUValue = defaultFeedback
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.fundamentalFrequency.associate(with: self.internalAU, value: fundamentalFrequency)
            self.feedback.associate(with: self.internalAU, value: feedback)

            input?.connect(to: self)
        }
    }
}
