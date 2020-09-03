// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
public class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let distortionDef = AKNodeParameterDef(
        identifier: "distortion",
        name: "Distortion (%)",
        address: akGetParameterAddress("AKThreePoleLowpassFilterParameterDistortion"),
        range: 0.0 ... 2.0,
        unit: .percent,
        flags: .default)

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by
    /// the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    @Parameter public var distortion: AUValue

    public static let cutoffFrequencyDef = AKNodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("AKThreePoleLowpassFilterParameterCutoffFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Filter cutoff frequency in Hertz.
    @Parameter public var cutoffFrequency: AUValue

    public static let resonanceDef = AKNodeParameterDef(
        identifier: "resonance",
        name: "Resonance (%)",
        address: akGetParameterAddress("AKThreePoleLowpassFilterParameterResonance"),
        range: 0.0 ... 2.0,
        unit: .percent,
        flags: .default)

    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency.
    /// Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    @Parameter public var resonance: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKThreePoleLowpassFilter.distortionDef,
             AKThreePoleLowpassFilter.cutoffFrequencyDef,
             AKThreePoleLowpassFilter.resonanceDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKThreePoleLowpassFilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - distortion: Distortion amount.  Zero gives a clean output.
    ///     Greater than zero adds tanh distortion controlled by the filter parameters,
    ///     in such a way that both low cutoff and high resonance increase the distortion amount.
    ///   - cutoffFrequency: Filter cutoff frequency in Hertz.
    ///   - resonance: Resonance. Usually a value in the range 0-1.
    ///     A value of 1.0 will self oscillate at the cutoff frequency. Values slightly greater than 1 are
    ///     possible for more sustained oscillation and an “overdrive” effect.
    ///
    public init(
        _ input: AKNode? = nil,
        distortion: AUValue = 0.5,
        cutoffFrequency: AUValue = 1_500,
        resonance: AUValue = 0.5
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.distortion = distortion
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
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
