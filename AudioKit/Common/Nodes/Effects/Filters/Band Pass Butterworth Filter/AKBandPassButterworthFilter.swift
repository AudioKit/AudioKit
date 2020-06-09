// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKBandPassButterworthFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btbp")

    public typealias AKAudioUnitType = AKBandPassButterworthFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<AUValue> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange: ClosedRange<AUValue> = 0.0 ... 20_000.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: AUValue = 2_000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth: AUValue = 100.0

    /// Center frequency. (in Hertz)
    public let centerFrequency = AKNodeParameter(identifier: "centerFrequency")

    /// Bandwidth. (in Hertz)
    public let bandwidth = AKNodeParameter(identifier: "bandwidth")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: Bandwidth. (in Hertz)
    ///
    public init(
        _ input: AKNode? = nil,
        centerFrequency: AUValue = defaultCenterFrequency,
        bandwidth: AUValue = defaultBandwidth
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.centerFrequency.associate(with: self.internalAU, value: centerFrequency)
            self.bandwidth.associate(with: self.internalAU, value: bandwidth)

            input?.connect(to: self)
        }
    }
}
