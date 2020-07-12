// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
open class AKPeakingParametricEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "peq0")

    public typealias AKAudioUnitType = AKPeakingParametricEqualizerFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Center frequency.
    @Parameter public var centerFrequency: AUValue

    /// Amount at which the center frequency value shall be increased or decreased. A value of 1 is a flat response.
    @Parameter public var gain: AUValue

    /// Q of the filter. sqrt(0.5) is no resonance.
    @Parameter public var q: AUValue

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency.
    ///   - gain: Amount at which the center frequency value shall be changed. A value of 1 is a flat response.
    ///   - q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = 1_000,
        gain: AUValue = 1.0,
        q: AUValue = 0.707
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.centerFrequency = centerFrequency
        self.gain = gain
        self.q = q
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
