// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Triggerable classic ADSR envelope
///
open class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    public typealias AKAudioUnitType = AKAmplitudeEnvelopeAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange: ClosedRange<AUValue> = 0 ... 99

    /// Lower and upper bounds for Decay Duration
    public static let decayDurationRange: ClosedRange<AUValue> = 0 ... 99

    /// Lower and upper bounds for Sustain Level
    public static let sustainLevelRange: ClosedRange<AUValue> = 0 ... 99

    /// Lower and upper bounds for Release Duration
    public static let releaseDurationRange: ClosedRange<AUValue> = 0 ... 99

    /// Initial value for Attack Duration
    public static let defaultAttackDuration: AUValue = 0.1

    /// Initial value for Decay Duration
    public static let defaultDecayDuration: AUValue = 0.1

    /// Initial value for Sustain Level
    public static let defaultSustainLevel: AUValue = 1.0

    /// Initial value for Release Duration
    public static let defaultReleaseDuration: AUValue = 0.1

    /// Attack time
    public let attackDuration = AKNodeParameter(identifier: "attackDuration")

    /// Decay time
    public let decayDuration = AKNodeParameter(identifier: "decayDuration")

    /// Sustain Level
    public let sustainLevel = AKNodeParameter(identifier: "sustainLevel")

    /// Release time
    public let releaseDuration = AKNodeParameter(identifier: "releaseDuration")

    // MARK: - Initialization

    /// Initialize this envelope node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackDuration: Attack time
    ///   - decayDuration: Decay time
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release time
    ///
    public init(
        _ input: AKNode? = nil,
        attackDuration: AUValue = defaultAttackDuration,
        decayDuration: AUValue = defaultDecayDuration,
        sustainLevel: AUValue = defaultSustainLevel,
        releaseDuration: AUValue = defaultReleaseDuration
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.attackDuration.associate(with: self.internalAU, value: attackDuration)
            self.decayDuration.associate(with: self.internalAU, value: decayDuration)
            self.sustainLevel.associate(with: self.internalAU, value: sustainLevel)
            self.releaseDuration.associate(with: self.internalAU, value: releaseDuration)

            input?.connect(to: self)
        }
    }
}
