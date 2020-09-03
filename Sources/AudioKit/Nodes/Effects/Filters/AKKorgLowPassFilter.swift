// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Analogue model of the Korg 35 Lowpass Filter
///
public class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let cutoffFrequencyDef = AKNodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Filter cutoff",
        address: akGetParameterAddress("AKKorgLowPassFilterParameterCutoffFrequency"),
        range: 0.0 ... 22_050.0,
        unit: .hertz,
        flags: .default)

    /// Filter cutoff
    @Parameter public var cutoffFrequency: AUValue

    public static let resonanceDef = AKNodeParameterDef(
        identifier: "resonance",
        name: "Filter resonance (should be between 0-2)",
        address: akGetParameterAddress("AKKorgLowPassFilterParameterResonance"),
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    /// Filter resonance (should be between 0-2)
    @Parameter public var resonance: AUValue

    public static let saturationDef = AKNodeParameterDef(
        identifier: "saturation",
        name: "Filter saturation.",
        address: akGetParameterAddress("AKKorgLowPassFilterParameterSaturation"),
        range: 0.0 ... 10.0,
        unit: .generic,
        flags: .default)

    /// Filter saturation.
    @Parameter public var saturation: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKKorgLowPassFilter.cutoffFrequencyDef,
             AKKorgLowPassFilter.resonanceDef,
             AKKorgLowPassFilter.saturationDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKKorgLowPassFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Filter cutoff
    ///   - resonance: Filter resonance (should be between 0-2)
    ///   - saturation: Filter saturation.
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 1_000.0,
        resonance: AUValue = 1.0,
        saturation: AUValue = 0.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.saturation = saturation
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
