// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// These filters are Butterworth second-order IIR filters. They offer an almost
/// flat passband and very good precision and stopband attenuation.
///
open class AKBandRejectButterworthFilter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBandRejectButterworthFilterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "btbr")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Center Frequency
    public static let centerFrequencyRange: ClosedRange<Double> = 12.0 ... 20_000.0

    /// Lower and upper bounds for Bandwidth
    public static let bandwidthRange: ClosedRange<Double> = 0.0 ... 20_000.0

    /// Initial value for Center Frequency
    public static let defaultCenterFrequency: Double = 3_000.0

    /// Initial value for Bandwidth
    public static let defaultBandwidth: Double = 2_000.0

    /// Center frequency. (in Hertz)
    open var centerFrequency: Double = defaultCenterFrequency {
        willSet {
            let clampedValue = AKBandRejectButterworthFilter.centerFrequencyRange.clamp(newValue)
            guard centerFrequency != clampedValue else { return }
            internalAU?.centerFrequency.value = AUValue(clampedValue)
        }
    }

    /// Bandwidth. (in Hertz)
    open var bandwidth: Double = defaultBandwidth {
        willSet {
            let clampedValue = AKBandRejectButterworthFilter.bandwidthRange.clamp(newValue)
            guard bandwidth != clampedValue else { return }
            internalAU?.bandwidth.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

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
        centerFrequency: Double = defaultCenterFrequency,
        bandwidth: Double = defaultBandwidth
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.centerFrequency = centerFrequency
            self.bandwidth = bandwidth
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
