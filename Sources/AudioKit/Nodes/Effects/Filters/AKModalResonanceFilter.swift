// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// A modal resonance filter used for modal synthesis. Plucked and bell sounds
/// can be created using  passing an impulse through a combination of modal
/// filters.
///
public class AKModalResonanceFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "modf")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let frequencyDef = AKNodeParameterDef(
        identifier: "frequency",
        name: "Resonant Frequency (Hz)",
        address: akGetParameterAddress("AKModalResonanceFilterParameterFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Resonant frequency of the filter.
    @Parameter public var frequency: AUValue

    public static let qualityFactorDef = AKNodeParameterDef(
        identifier: "qualityFactor",
        name: "Quality Factor",
        address: akGetParameterAddress("AKModalResonanceFilterParameterQualityFactor"),
        range: 0.0 ... 100.0,
        unit: .generic,
        flags: .default)

    /// Quality factor of the filter. Roughly equal to Q/frequency.
    @Parameter public var qualityFactor: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKModalResonanceFilter.frequencyDef,
             AKModalResonanceFilter.qualityFactorDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKModalResonanceFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Resonant frequency of the filter.
    ///   - qualityFactor: Quality factor of the filter. Roughly equal to Q/frequency.
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = 500.0,
        qualityFactor: AUValue = 50.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.frequency = frequency
        self.qualityFactor = qualityFactor
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
