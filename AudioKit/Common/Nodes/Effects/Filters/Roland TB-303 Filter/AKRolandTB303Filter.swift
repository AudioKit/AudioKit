// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Emulation of the Roland TB-303 filter
///
open class AKRolandTB303Filter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "tb3f")

    public typealias AKAudioUnitType = AKRolandTB303FilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Lower and upper bounds for Distortion
    public static let distortionRange: ClosedRange<AUValue> = 0.0 ... 4.0

    /// Lower and upper bounds for Resonance Asymmetry
    public static let resonanceAsymmetryRange: ClosedRange<AUValue> = 0.0 ... 1.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: AUValue = 500

    /// Initial value for Resonance
    public static let defaultResonance: AUValue = 0.5

    /// Initial value for Distortion
    public static let defaultDistortion: AUValue = 2.0

    /// Initial value for Resonance Asymmetry
    public static let defaultResonanceAsymmetry: AUValue = 0.5

    /// Cutoff frequency. (in Hertz)
    public let cutoffFrequency = AKNodeParameter(identifier: "cutoffFrequency")

    /// Resonance, generally < 1, but not limited to it.
    /// Higher than 1 resonance values might cause aliasing,
    /// analogue synths generally allow resonances to be above 1.
    public let resonance = AKNodeParameter(identifier: "resonance")

    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    public let distortion = AKNodeParameter(identifier: "distortion")

    /// Asymmetry of resonance. Value is between 0-1
    public let resonanceAsymmetry = AKNodeParameter(identifier: "resonanceAsymmetry")

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
        cutoffFrequency: AUValue = defaultCutoffFrequency,
        resonance: AUValue = defaultResonance,
        distortion: AUValue = defaultDistortion,
        resonanceAsymmetry: AUValue = defaultResonanceAsymmetry
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.cutoffFrequency.associate(with: self.internalAU, value: cutoffFrequency)
            self.resonance.associate(with: self.internalAU, value: resonance)
            self.distortion.associate(with: self.internalAU, value: distortion)
            self.resonanceAsymmetry.associate(with: self.internalAU, value: resonanceAsymmetry)

            input?.connect(to: self)
        }
    }
}
