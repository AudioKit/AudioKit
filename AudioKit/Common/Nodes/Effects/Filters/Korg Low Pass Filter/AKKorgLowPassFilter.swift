// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Analogue model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Filter cutoff
    @Parameter public var cutoffFrequency: AUValue

    /// Filter resonance (should be between 0-2)
    @Parameter public var resonance: AUValue

    /// Filter saturation.
    @Parameter public var saturation: AUValue

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

            input?.connect(to: self)
        }
    }
}
