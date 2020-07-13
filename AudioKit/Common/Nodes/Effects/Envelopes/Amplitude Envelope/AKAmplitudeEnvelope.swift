// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Triggerable classic ADSR envelope
///
open class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    public typealias AKAudioUnitType = AKAmplitudeEnvelopeAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Attack time
    @Parameter public var attackDuration: AUValue

    /// Decay time
    @Parameter public var decayDuration: AUValue

    /// Sustain Level
    @Parameter public var sustainLevel: AUValue

    /// Release time
    @Parameter public var releaseDuration: AUValue

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
        attackDuration: AUValue = 0.1,
        decayDuration: AUValue = 0.1,
        sustainLevel: AUValue = 1.0,
        releaseDuration: AUValue = 0.1
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
