// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Analogue model of the Korg 35 Lowpass Filter
///
open class AKKorgLowPassFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "klpf")

    public typealias AKAudioUnitType = AKKorgLowPassFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<AUValue> = 0.0 ... 22_050.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Lower and upper bounds for Saturation
    public static let saturationRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: AUValue = 1_000.0

    /// Initial value for Resonance
    public static let defaultResonance: AUValue = 1.0

    /// Initial value for Saturation
    public static let defaultSaturation: AUValue = 0.0

    /// Filter cutoff
    public let cutoffFrequency = AKNodeParameter(identifier: "cutoffFrequency")

    /// Filter resonance (should be between 0-2)
    public let resonance = AKNodeParameter(identifier: "resonance")

    /// Filter saturation.
    public let saturation = AKNodeParameter(identifier: "saturation")

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
        cutoffFrequency: AUValue = defaultCutoffFrequency,
        resonance: AUValue = defaultResonance,
        saturation: AUValue = defaultSaturation
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.cutoffFrequency.associate(with: self.internalAU, value: cutoffFrequency)
            self.resonance.associate(with: self.internalAU, value: resonance)
            self.saturation.associate(with: self.internalAU, value: saturation)

            input?.connect(to: self)
        }
    }
}
