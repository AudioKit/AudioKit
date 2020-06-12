// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// 3-pole (18 db/oct slope) Low-Pass filter with resonance and tanh distortion.
///
open class AKThreePoleLowpassFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "lp18")

    public typealias AKAudioUnitType = AKThreePoleLowpassFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Distortion
    public static let distortionRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Resonance
    public static let resonanceRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Initial value for Distortion
    public static let defaultDistortion: AUValue = 0.5

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: AUValue = 1_500

    /// Initial value for Resonance
    public static let defaultResonance: AUValue = 0.5

    /// Distortion amount.  Zero gives a clean output. Greater than zero adds tanh distortion controlled by
    /// the filter parameters, in such a way that both low cutoff and high resonance increase the distortion amount.
    public let distortion = AKNodeParameter(identifier: "distortion")

    /// Filter cutoff frequency in Hertz.
    public let cutoffFrequency = AKNodeParameter(identifier: "cutoffFrequency")

    /// Resonance. Usually a value in the range 0-1. A value of 1.0 will self oscillate at the cutoff frequency.
    /// Values slightly greater than 1 are possible for more sustained oscillation and an “overdrive” effect.
    public let resonance = AKNodeParameter(identifier: "resonance")

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
        distortion: AUValue = defaultDistortion,
        cutoffFrequency: AUValue = defaultCutoffFrequency,
        resonance: AUValue = defaultResonance
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.distortion.associate(with: self.internalAU, value: distortion)
            self.cutoffFrequency.associate(with: self.internalAU, value: cutoffFrequency)
            self.resonance.associate(with: self.internalAU, value: resonance)

            input?.connect(to: self)
        }
    }
}
