// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Karplus-Strong plucked string instrument.
///
open class AKPluckedString: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKPluckedStringAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "pluk")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0 ... 22_000

    /// Lower and upper bounds for Amplitude
    public static let amplitudeRange: ClosedRange<Double> = 0 ... 1

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 110

    /// Initial value for Amplitude
    public static let defaultAmplitude: Double = 0.5

    /// Initial value for Lowest Frequency
    public static let defaultLowestFrequency: Double = 110

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKPluckedString.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Amplitude
    open var amplitude: Double = defaultAmplitude {
        willSet {
            let clampedValue = AKPluckedString.amplitudeRange.clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this pluck node
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    ///   - amplitude: Amplitude
    ///   - lowestFrequency: This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.
    ///
    public init(
        frequency: Double = defaultFrequency,
        amplitude: Double = defaultAmplitude,
        lowestFrequency: Double = defaultLowestFrequency
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.frequency = frequency
            self.amplitude = amplitude
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
