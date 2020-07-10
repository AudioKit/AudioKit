// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Flanger
///
open class AKFlanger: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "flgr")

    public typealias AKAudioUnitType = AKFlangerAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let frequencyRange: ClosedRange<AUValue> = kAKFlanger_MinFrequency ... kAKFlanger_MaxFrequency
    public static let depthRange: ClosedRange<AUValue> = kAKFlanger_MinDepth ... kAKFlanger_MaxDepth
    public static let feedbackRange: ClosedRange<AUValue> = kAKFlanger_MinFeedback ... kAKFlanger_MaxFeedback
    public static let dryWetMixRange: ClosedRange<AUValue> = kAKFlanger_MinDryWetMix ... kAKFlanger_MaxDryWetMix

    public static let defaultFrequency: AUValue = kAKFlanger_DefaultFrequency
    public static let defaultDepth: AUValue = kAKFlanger_DefaultDepth
    public static let defaultFeedback: AUValue = kAKFlanger_DefaultFeedback
    public static let defaultDryWetMix: AUValue = kAKFlanger_DefaultDryWetMix

    /// Modulation Frequency (Hz)
    public var frequency = AKNodeParameter(identifier: "frequency")

    /// Modulation Depth (fraction)
    public var depth = AKNodeParameter(identifier: "depth")

    /// Feedback (fraction)
    public var feedback = AKNodeParameter(identifier: "feedback")

    /// Dry Wet Mix (fraction)
    public var dryWetMix = AKNodeParameter(identifier: "dryWetMix")

    // MARK: - Initialization

    /// Initialize this flanger node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix  - traditionally 50%, avoid changing this value
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = defaultFrequency,
        depth: AUValue = defaultDepth,
        feedback: AUValue = defaultFeedback,
        dryWetMix: AUValue = defaultDryWetMix
    ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
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
