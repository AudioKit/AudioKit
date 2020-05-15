// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Table-lookup tremolo with linear interpolation
///
open class AKTremolo: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKTremoloAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "trem")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Frequency
    public static let frequencyRange: ClosedRange<Double> = 0.0 ... 100.0

    /// Lower and upper bounds for Depth
    public static let depthRange: ClosedRange<Double> = 0.0 ... 1.0

    /// Initial value for Frequency
    public static let defaultFrequency: Double = 10.0

    /// Initial value for Depth
    public static let defaultDepth: Double = 1.0

    /// Frequency (Hz)
    @objc open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKTremolo.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Depth
    @objc open var depth: Double = defaultDepth {
        willSet {
            let clampedValue = AKTremolo.depthRange.clamp(newValue)
            guard depth != clampedValue else { return }
            internalAU?.depth.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this tremolo node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - frequency: Frequency (Hz)
    ///   - depth: Depth
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: Double = defaultFrequency,
        depth: Double = defaultDepth,
        waveform: AKTable = AKTable(.positiveSine)
        ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.frequency = frequency
            self.depth = depth
            self.internalAU?.setWavetable(waveform.content)
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
