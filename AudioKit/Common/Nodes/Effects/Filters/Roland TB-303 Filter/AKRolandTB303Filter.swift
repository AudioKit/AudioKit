// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Emulation of the Roland TB-303 filter
///
open class AKRolandTB303Filter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "tb3f")

    public typealias AKAudioUnitType = AKRolandTB303FilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Cutoff frequency. (in Hertz)
    @Parameter public var cutoffFrequency: AUValue

    /// Resonance, generally < 1, but not limited to it.
    /// Higher than 1 resonance values might cause aliasing,
    /// analogue synths generally allow resonances to be above 1.
    @Parameter public var resonance: AUValue

    /// Distortion. Value is typically 2.0; deviation from this can cause stability issues. 
    @Parameter public var distortion: AUValue

    /// Asymmetry of resonance. Value is between 0-1
    @Parameter public var resonanceAsymmetry: AUValue

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

            input?.connect(to: self)
        }
    }
}
