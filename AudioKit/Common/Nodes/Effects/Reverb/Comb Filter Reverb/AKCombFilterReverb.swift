// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This filter reiterates input with an echo density determined by
/// loopDuration. The attenuation rate is independent and is determined by
/// reverbDuration, the reverberation duration (defined as the time in seconds
/// for a signal to decay to 1/1000, or 60dB down from its original amplitude).
/// Output from a comb filter will appear only after loopDuration seconds.
///
open class AKCombFilterReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKCombFilterReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "comb")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Reverb Duration
    public static let reverbDurationRange: ClosedRange<Double> = 0.0 ... 10.0

    /// Initial value for Reverb Duration
    public static let defaultReverbDuration: Double = 1.0

    /// Initial value for Loop Duration
    public static let defaultLoopDuration: Double = 0.1

    /// The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    @objc open var reverbDuration: Double = defaultReverbDuration {
        willSet {
            let clampedValue = AKCombFilterReverb.reverbDurationRange.clamp(newValue)
            guard reverbDuration != clampedValue else { return }
            internalAU?.reverbDuration.value = AUValue(clampedValue)
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
    ///   - reverbDuration: The time in seconds for a signal to decay to 1/1000, or 60dB from its original amplitude. (aka RT-60).
    ///   - loopDuration: The loop time of the filter, in seconds. This can also be thought of as the delay time. Determines frequency response curve, loopDuration * sr/2 peaks spaced evenly between 0 and sr/2.
    ///
    public init(
        _ input: AKNode? = nil,
        reverbDuration: Double = defaultReverbDuration,
        loopDuration: Double = defaultLoopDuration
        ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.reverbDuration = reverbDuration
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
