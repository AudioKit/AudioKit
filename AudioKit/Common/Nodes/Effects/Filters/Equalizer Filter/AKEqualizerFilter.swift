// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// A 2nd order tunable equalization filter that provides a peak/notch filter
/// for building parametric/graphic equalizers. With gain above 1, there will be
/// a peak at the center frequency with a width dependent on bandwidth. If gain
/// is less than 1, a notch is formed around the center frequency.
///
open class AKEqualizerFilter: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(effect: "eqfl")

    public typealias AKAudioUnitType = AKEqualizerFilterAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Center frequency. (in Hertz)
    @Parameter public var centerFrequency: AUValue

    /// The peak/notch bandwidth in Hertz
    @Parameter public var bandwidth: AUValue

    /// The peak/notch gain
    @Parameter public var gain: AUValue

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
        centerFrequency: AUValue = 1_000.0,
        bandwidth: AUValue = 100.0,
        gain: AUValue = 10.0
        ) {
        super.init(avAudioNode: AVAudioNode())
        self.centerFrequency = centerFrequency
        self.bandwidth = bandwidth
        self.gain = gain
        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)

            input?.connect(to: self)
        }
    }
}
