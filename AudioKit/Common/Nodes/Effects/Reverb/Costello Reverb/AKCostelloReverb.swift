// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
/// modeling scattering junction of 8 lossless waveguides of equal
/// characteristic impedance.
///
open class AKCostelloReverb: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "rvsc")

    public typealias AKAudioUnitType = AKCostelloReverbAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Initial value for Feedback
    public static let defaultFeedback: AUValue = 0.6

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: AUValue = 4_000.0

    /// Feedback level in the range 0 to 1. 0.6 is good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall.
    /// A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    public let feedback = AKNodeParameter(identifier: "feedback")

    /// Low-pass cutoff frequency.
    public let cutoffFrequency = AKNodeParameter(identifier: "cutoffFrequency")

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - feedback: Feedback level in the range 0 to 1.
    ///     0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall.
    ///     A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    ///   - cutoffFrequency: Low-pass cutoff frequency.
    ///
    public init(
        _ input: AKNode? = nil,
        feedback: AUValue = defaultFeedback,
        cutoffFrequency: AUValue = defaultCutoffFrequency
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.feedback.associate(with: self.internalAU, value: feedback)
            self.cutoffFrequency.associate(with: self.internalAU, value: cutoffFrequency)

            input?.connect(to: self)
        }
    }
}
