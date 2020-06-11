// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A 2nd order tunable equalization filter that provides a peak/notch filter
/// for building parametric/graphic equalizers. With gain above 1, there will be
/// a peak at the center frequency with a width dependent on bandwidth. If gain
/// is less than 1, a notch is formed around the center frequency.
///
open class AKEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "eqfl")

    public typealias AKAudioUnitType = AKEqualizerFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange: ClosedRange<AUValue> = 0.0 ... 20_000.0

    /// Lower and upper bounds for Gain
    public static let gainRange: ClosedRange<AUValue> = -100.0 ... 100.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: AUValue = 1_000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth: AUValue = 100.0

    /// Initial value for Gain
    public static let defaultGain: AUValue = 10.0

    /// Center frequency. (in Hertz)
    public let centerFrequency = AKNodeParameter(identifier: "centerFrequency")

    /// The peak/notch bandwidth in Hertz
    public let bandwidth = AKNodeParameter(identifier: "bandwidth")

    /// The peak/notch gain
    public let gain = AKNodeParameter(identifier: "gain")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: The peak/notch bandwidth in Hertz
    ///   - gain: The peak/notch gain
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = defaultCenterFrequency,
        bandwidth: AUValue = defaultBandwidth,
        gain: AUValue = defaultGain
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.centerFrequency.associate(with: self.internalAU, value: centerFrequency)
            self.bandwidth.associate(with: self.internalAU, value: bandwidth)
            self.gain.associate(with: self.internalAU, value: gain)

            input?.connect(to: self)
        }
    }
}
