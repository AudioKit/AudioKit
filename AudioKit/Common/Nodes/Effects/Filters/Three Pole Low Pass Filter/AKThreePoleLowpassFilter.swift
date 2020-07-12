// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
open class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    public typealias AKAudioUnitType = AKThreePoleLowpassFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by
    /// the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    @Parameter public var distortion: AUValue

    /// Filter cutoff frequency in Hertz.
    @Parameter public var cutoffFrequency: AUValue

    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency.
    /// Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    @Parameter public var resonance: AUValue

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

            input?.connect(to: self)
        }
    }
}
