// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// The output for reson appears to be very hot, so take caution when using this
/// module.
///
open class AKResonantFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "resn")

    public typealias AKAudioUnitType = AKResonantFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 100.0 ... 20_000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange: ClosedRange<AUValue> = 0.0 ... 10_000.0

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 4_000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth: AUValue = 1_000.0

    /// Center frequency of the filter, or frequency position of the peak response.
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Bandwidth of the filter.
    public let bandwidth = AKNodeParameter(identifier: "bandwidth")

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Center frequency of the filter, or frequency position of the peak response.
    ///   - bandwidth: Bandwidth of the filter.
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: AUValue = defaultFrequency,
        bandwidth: AUValue = defaultBandwidth
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.bandwidth.associate(with: self.internalAU, value: bandwidth)

            input?.connect(to: self)
        }
    }
}
