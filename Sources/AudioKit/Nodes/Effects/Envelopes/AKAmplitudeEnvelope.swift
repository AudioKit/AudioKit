// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Triggerable classic ADSR envelope
///
public class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let attackDurationDef = AKNodeParameterDef(
        identifier: "attackDuration",
        name: "Attack time",
        address: akGetParameterAddress("AKAmplitudeEnvelopeParameterAttackDuration"),
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    /// Attack time
    @Parameter public var attackDuration: AUValue

    public static let decayDurationDef = AKNodeParameterDef(
        identifier: "decayDuration",
        name: "Decay time",
        address: akGetParameterAddress("AKAmplitudeEnvelopeParameterDecayDuration"),
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    /// Decay time
    @Parameter public var decayDuration: AUValue

    public static let sustainLevelDef = AKNodeParameterDef(
        identifier: "sustainLevel",
        name: "Sustain Level",
        address: akGetParameterAddress("AKAmplitudeEnvelopeParameterSustainLevel"),
        range: 0 ... 99,
        unit: .generic,
        flags: .default)

    /// Sustain Level
    @Parameter public var sustainLevel: AUValue

    public static let releaseDurationDef = AKNodeParameterDef(
        identifier: "releaseDuration",
        name: "Release time",
        address: akGetParameterAddress("AKAmplitudeEnvelopeParameterReleaseDuration"),
        range: 0 ... 99,
        unit: .seconds,
        flags: .default)

    /// Release time
    @Parameter public var releaseDuration: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKAmplitudeEnvelope.attackDurationDef,
             AKAmplitudeEnvelope.decayDurationDef,
             AKAmplitudeEnvelope.sustainLevelDef,
             AKAmplitudeEnvelope.releaseDurationDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKAmplitudeEnvelopeDSP")
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
        }

        if let input = input {
            connections.append(input)
        }
    }
}
