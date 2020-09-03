// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// When fed with a pulse train, it will generate a series of overlapping
/// grains. Overlapping will occur when 1/freq < dec, but there is no upper
/// limit on the number of overlaps.
///
public class AKFormantFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "fofi")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let centerFrequencyDef = AKNodeParameterDef(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: akGetParameterAddress("AKFormantFilterParameterCenterFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency.
    @Parameter public var centerFrequency: AUValue

    public static let attackDurationDef = AKNodeParameterDef(
        identifier: "attackDuration",
        name: "Impulse response attack time (Seconds)",
        address: akGetParameterAddress("AKFormantFilterParameterAttackDuration"),
        range: 0.0 ... 0.1,
        unit: .seconds,
        flags: .default)

    /// Impulse response attack time (in seconds).
    @Parameter public var attackDuration: AUValue

    public static let decayDurationDef = AKNodeParameterDef(
        identifier: "decayDuration",
        name: "Impulse reponse decay time (Seconds)",
        address: akGetParameterAddress("AKFormantFilterParameterDecayDuration"),
        range: 0.0 ... 0.1,
        unit: .seconds,
        flags: .default)

    /// Impulse reponse decay time (in seconds)
    @Parameter public var decayDuration: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKFormantFilter.centerFrequencyDef,
             AKFormantFilter.attackDurationDef,
             AKFormantFilter.decayDurationDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKFormantFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency.
    ///   - attackDuration: Impulse response attack time (in seconds).
    ///   - decayDuration: Impulse reponse decay time (in seconds)
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = 1_000,
        attackDuration: AUValue = 0.007,
        decayDuration: AUValue = 0.04
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.centerFrequency = centerFrequency
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
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
