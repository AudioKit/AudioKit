// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Triggerable classic ADSR envelope
///
public class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    static let attackDurationDef = AKNodeParameterDef(
        identifier: "attackDuration",
        name: "Attack time",
        address: AKAmplitudeEnvelopeParameter.attackDuration.rawValue,
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    /// Attack time
    @Parameter public var attackDuration: AUValue

    static let decayDurationDef = AKNodeParameterDef(
        identifier: "decayDuration",
        name: "Decay time",
        address: AKAmplitudeEnvelopeParameter.decayDuration.rawValue,
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    /// Decay time
    @Parameter public var decayDuration: AUValue

    static let sustainLevelDef = AKNodeParameterDef(
        identifier: "sustainLevel",
        name: "Sustain Level",
        address: AKAmplitudeEnvelopeParameter.sustainLevel.rawValue,
        range: 0 ... 99,
        unit: .generic,
        flags: .default)

    /// Sustain Level
    @Parameter public var sustainLevel: AUValue

    static let releaseDurationDef = AKNodeParameterDef(
        identifier: "releaseDuration",
        name: "Release time",
        address: AKAmplitudeEnvelopeParameter.releaseDuration.rawValue,
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    /// Release time
    @Parameter public var releaseDuration: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            return [AKAmplitudeEnvelope.attackDurationDef,
                    AKAmplitudeEnvelope.decayDurationDef,
                    AKAmplitudeEnvelope.sustainLevelDef,
                    AKAmplitudeEnvelope.releaseDurationDef]
        }

        public override func createDSP() -> AKDSPRef {
            return createAmplitudeEnvelopeDSP()
        }
    }

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
