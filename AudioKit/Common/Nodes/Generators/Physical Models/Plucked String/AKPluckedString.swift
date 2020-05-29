// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Karplus-Strong plucked string instrument.
///
open class AKPluckedString: AKNode, AKToggleable, AKComponent, AKAutomatable {

    // MARK: - AKComponent

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pluk")

    public typealias AKAudioUnitType = AKPluckedStringAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    // MARK: - AKAutomatable

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<AUValue> = 0 ... 22_000

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<AUValue> = 0 ... 1

    /// Initial value for Frequency
    public static let defaultFrequency: AUValue = 110

    /// Initial value for Amplitude
    public static let defaultAmplitude: AUValue = 0.5

    /// Initial value for Lowest Frequency
    public static let defaultLowestFrequency: AUValue = 110

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    public let frequency = AKNodeParameter(identifier: "frequency")

    /// Amplitude
    public let amplitude = AKNodeParameter(identifier: "amplitude")

    // MARK: - Initialization

    /// Initialize this pluck node
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    ///   - amplitude: Amplitude
    ///   - lowestFrequency: This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.
    ///
    public init(
        frequency: AUValue = defaultFrequency,
        amplitude: AUValue = defaultAmplitude,
        lowestFrequency: AUValue = defaultLowestFrequency
    ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(self.internalAU, avAudioUnit: avAudioUnit)

            self.frequency.associate(with: self.internalAU, value: frequency)
            self.amplitude.associate(with: self.internalAU, value: amplitude)
        }

    }
}
