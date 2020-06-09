// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This is an implementation of Zoelzer's parametric equalizer filter.
///
open class AKHighShelfParametricEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "peq2")

    public typealias AKAudioUnitType = AKHighShelfParametricEqualizerFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Gain
    public static let gainRange: ClosedRange<AUValue> = 0.0 ... 10.0

    /// Lower and upper bounds for Q
    public static let qRange: ClosedRange<AUValue> = 0.0 ... 2.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: AUValue = 1_000

    /// Initial value for Gain
    public static let defaultGain: AUValue = 1.0

    /// Initial value for Q
    public static let defaultQ: AUValue = 0.707

    /// Corner frequency.
    public let centerFrequency = AKNodeParameter(identifier: "centerFrequency")

    /// Amount at which the corner frequency value shall be increased or decreased. A value of 1 is a flat response.
    public let gain = AKNodeParameter(identifier: "gain")

    /// Q of the filter. sqrt(0.5) is no resonance.
    public let q = AKNodeParameter(identifier: "q")

    // MARK: - Initialization

    /// Initialize this equalizer node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Corner frequency.
    ///   - gain: Amount at which the corner frequency value shall be changed. A value of 1 is a flat response.
    ///   - q: Q of the filter. sqrt(0.5) is no resonance.
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = defaultCenterFrequency,
        gain: AUValue = defaultGain,
        q: AUValue = defaultQ
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.centerFrequency.associate(with: self.internalAU, value: centerFrequency)
            self.gain.associate(with: self.internalAU, value: gain)
            self.q.associate(with: self.internalAU, value: q)

            input?.connect(to: self)
        }
    }
}
