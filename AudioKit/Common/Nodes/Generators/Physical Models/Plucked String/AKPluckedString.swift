// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Karplus-Strong plucked string instrument.
///
open class AKPluckedString: AKNode, AKToggleable, AKComponent, AKAutomatable {

    public static let ComponentDescription = AudioComponentDescription(generator: "pluk")

    public typealias AKAudioUnitType = AKPluckedStringAudioUnit

    public private(set) var internalAU: AKAudioUnitType?

    public private(set) var parameterAutomation: AKParameterAutomation?

    // MARK: - Parameters

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    @Parameter public var frequency: AUValue

    /// Amplitude
    @Parameter public var amplitude: AUValue

    // MARK: - Initialization

    /// Initialize this pluck node
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than initial frequency will be doubled until greater than that.
    ///   - amplitude: Amplitude
    ///   - lowestFrequency: This frequency is used to allocate all the buffers needed for the delay.
    ///   This should be the lowest frequency you plan on using.
    ///
    public init(
        frequency: AUValue = 110,
        amplitude: AUValue = 0.5,
        lowestFrequency: AUValue = 110
    ) {
        super.init(avAudioNode: AVAudioNode())

        self.frequency = frequency
        self.amplitude = amplitude

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            self.parameterAutomation = AKParameterAutomation(avAudioUnit)
        }

    }
}
