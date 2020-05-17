// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Faust-based pitch shfiter
///
open class AKPitchShifter: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKPitchShifterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "pshf")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Shift
    public static let shiftRange: ClosedRange<Double> = -24.0 ... 24.0

    /// Lower and upper bounds for Window Size
    public static let windowSizeRange: ClosedRange<Double> = 0.0 ... 10_000.0

    /// Lower and upper bounds for Crossfade
    public static let crossfadeRange: ClosedRange<Double> = 0.0 ... 10_000.0

    /// Initial value for Shift
    public static let defaultShift: Double = 0

    /// Initial value for Window Size
    public static let defaultWindowSize: Double = 1_024

    /// Initial value for Crossfade
    public static let defaultCrossfade: Double = 512

    /// Pitch shift (in semitones)
    @objc open var shift: Double = defaultShift {
        willSet {
            let clampedValue = AKPitchShifter.shiftRange.clamp(newValue)
            guard shift != clampedValue else { return }
            internalAU?.shift.value = AUValue(clampedValue)
        }
    }

    /// Window size (in samples)
    @objc open var windowSize: Double = defaultWindowSize {
        willSet {
            let clampedValue = AKPitchShifter.windowSizeRange.clamp(newValue)
            guard windowSize != clampedValue else { return }
            internalAU?.windowSize.value = AUValue(clampedValue)
        }
    }

    /// Crossfade (in samples)
    @objc open var crossfade: Double = defaultCrossfade {
        willSet {
            let clampedValue = AKPitchShifter.crossfadeRange.clamp(newValue)
            guard crossfade != clampedValue else { return }
            internalAU?.crossfade.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this pitchshifter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - shift: Pitch shift (in semitones)
    ///   - windowSize: Window size (in samples)
    ///   - crossfade: Crossfade (in samples)
    ///
    public init(
        _ input: AKNode? = nil,
        shift: Double = defaultShift,
        windowSize: Double = defaultWindowSize,
        crossfade: Double = defaultCrossfade
        ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.shift = shift
            self.windowSize = windowSize
            self.crossfade = crossfade
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
