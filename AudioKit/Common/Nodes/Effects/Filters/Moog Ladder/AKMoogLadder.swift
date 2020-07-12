// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Moog Ladder is an new digital implementation of the Moog ladder filter based
/// on the work of Antti Huovilainen, described in the paper "Non-Linear Digital
/// Implementation of the Moog Ladder Filter" (Proceedings of DaFX04, Univ of
/// Napoli). This implementation is probably a more accurate digital
/// representation of the original analogue filter.
///
open class AKMoogLadder: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "mgld")

    public typealias AKAudioUnitType = AKMoogLadderAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Filter cutoff frequency.
    @Parameter public var cutoffFrequency: AUValue

    /// Resonance, generally < 1, but not limited to it.
    /// Higher than 1 resonance values might cause aliasing, analogue synths generally allow resonances to be above 1.
    @Parameter public var resonance: AUValue

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
        cutoffFrequency: AUValue = 1_000,
        resonance: AUValue = 0.5
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.cutoffFrequency = cutoffFrequency
        self.resonance = resonance
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
