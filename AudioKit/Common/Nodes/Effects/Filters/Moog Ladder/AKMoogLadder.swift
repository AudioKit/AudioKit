// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Moog Ladder is an new digital implementation of the Moog ladder filter based
/// on the work of Antti Huovilainen, described in the paper "Non-Linear Digital
/// Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of
/// Napoli). This implementation is probably a more accurate digital
/// representation of the original analogue filter.
///
open class AKMoogLadder: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "mgld")

    public typealias AKAudioUnitType = AKMoogLadderAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: AUValue = 1_000

    /// Initial value for Resonance
    public static let defaultResonance: AUValue = 0.5

    /// Filter cutoff frequency.
    public let cutoffFrequency = AKNodeParameter(identifier: "cutoffFrequency")

    /// Resonance, generally < 1, but not limited to it.
    /// Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    public let resonance = AKNodeParameter(identifier: "resonance")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Filter cutoff frequency.
    ///   - resonance: Resonance, generally < 1, but not limited to it.
    ///     Higher than 1 resonance values might cause aliasing,
    ///     analogue synths generally allow resonances to be above 1.
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: AUValue = defaultCutoffFrequency,
        resonance: AUValue = defaultResonance
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.cutoffFrequency.associate(with: self.internalAU, value: cutoffFrequency)
            self.resonance.associate(with: self.internalAU, value: resonance)

            input?.connect(to: self)
        }
    }
}
