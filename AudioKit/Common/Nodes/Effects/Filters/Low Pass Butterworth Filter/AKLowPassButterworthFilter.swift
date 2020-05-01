// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKLowPassButterworthFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKLowPassButterworthFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btlp")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency: Double = 1_000.0

    /// Cutoff frequency. (in Hertz)
    @objc open var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            let clampedValue = AKLowPassButterworthFilter.cutoffFrequencyRange.clamp(newValue)
            guard cutoffFrequency != clampedValue else { return }
            internalAU?.cutoffFrequency.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - cutoffFrequency: Cutoff frequency. (in Hertz)
    ///
    public init(
        _ input: AKNode? = nil,
        cutoffFrequency: Double = defaultCutoffFrequency
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.cutoffFrequency = cutoffFrequency
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
