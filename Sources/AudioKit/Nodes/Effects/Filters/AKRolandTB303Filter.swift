// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Emulation of the Roland TB-303 filter
///
public class AKRolandTB303Filter: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "tb3f")

    public typealias AKAudioUnitType = InternalAU

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    public static let cutoffFrequencyDef = AKNodeParameterDef(
        identifier: "cutoffFrequency",
        name: "Cutoff Frequency (Hz)",
        address: akGetParameterAddress("AKRolandTB303FilterParameterCutoffFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Cutoff frequency. (in Hertz)
    @Parameter public var cutoffFrequency: AUValue

    public static let resonanceDef = AKNodeParameterDef(
        identifier: "resonance",
        name: "Resonance",
        address: akGetParameterAddress("AKRolandTB303FilterParameterResonance"),
        range: 0.0 ... 2.0,
        unit: .generic,
        flags: .default)

    /// Resonance, generally < 1, but not limited to it.
    /// Higher than 1 resonance values might cause aliasing,
    /// analogue synths generally allow resonances to be above 1.
    @Parameter public var resonance: AUValue

    public static let distortionDef = AKNodeParameterDef(
        identifier: "distortion",
        name: "Distortion",
        address: akGetParameterAddress("AKRolandTB303FilterParameterDistortion"),
        range: 0.0 ... 4.0,
        unit: .generic,
        flags: .default)

    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    @Parameter public var distortion: AUValue

    public static let resonanceAsymmetryDef = AKNodeParameterDef(
        identifier: "resonanceAsymmetry",
        name: "Resonance Asymmetry",
        address: akGetParameterAddress("AKRolandTB303FilterParameterResonanceAsymmetry"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Asymmetry of resonance. Value is between 0-1
    @Parameter public var resonanceAsymmetry: AUValue

    // MARK: - Audio Unit

    public class InternalAU: AKAudioUnitBase {

        public override func getParameterDefs() -> [AKNodeParameterDef] {
            [AKRolandTB303Filter.cutoffFrequencyDef,
             AKRolandTB303Filter.resonanceDef,
             AKRolandTB303Filter.distortionDef,
             AKRolandTB303Filter.resonanceAsymmetryDef]
        }

        public override func createDSP() -> AKDSPRef {
            akCreateDSP("AKRolandTB303FilterDSP")
        }
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///   - resonance: Resonance, generally < 1, but not limited to it. Higher than 1 resonance values might
    ///     cause aliasing, analogue synths generally allow resonances to be above 1.
    ///   - distortion: Distortion. Value is typically 2.0; deviation from this can cause stability issues.
    ///   - resonanceAsymmetry: Asymmetry of resonance. Value is between 0-1
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = 500,
        resonance: AUValue = 0.5,
        distortion: AUValue = 2.0,
        resonanceAsymmetry: AUValue = 0.5
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        self.distortion = distortion
        self.resonanceAsymmetry = resonanceAsymmetry
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
