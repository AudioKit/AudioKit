// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Shane's Chorus
///
open class AKChorus: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "chrs")

    public typealias AKAudioUnitType = AKChorusAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0.1 ... 10.0

    /// Lower and upper bounds for Depth
    public static let depthRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange: ClosedRange<AUValue> = 0.0 ... 0.25

    /// Lower and upper bounds for Dry Wet Mix
    public static let dryWetMixRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 1.0

    /// Initial value for Depth
    public static let defaultDepth: AUValue = 0.0

    /// Initial value for Feedback
    public static let defaultFeedback: AUValue = 0.0

    /// Initial value for Dry Wet Mix
    public static let defaultDryWetMix: AUValue = 0.0

    /// Frequency. (in Hertz)
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Depth
    public let depth = AKNodeParameter(identifier: "depth")

    /// Feedback
    public let feedback = AKNodeParameter(identifier: "feedback")

    /// Dry Wet Mix
    public let dryWetMix = AKNodeParameter(identifier: "dryWetMix")

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
        frequency: AUValue = defaultFrequency,
        depth: AUValue = defaultDepth,
        feedback: AUValue = defaultFeedback,
        dryWetMix: AUValue = defaultDryWetMix
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.depth.associate(with: self.internalAU, value: depth)
            self.feedback.associate(with: self.internalAU, value: feedback)
            self.dryWetMix.associate(with: self.internalAU, value: dryWetMix)

            input?.connect(to: self)
        }
    }
}
