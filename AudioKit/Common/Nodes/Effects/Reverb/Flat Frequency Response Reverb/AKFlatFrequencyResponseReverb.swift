// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// This filter reiterates the input with an echo density determined by loop
/// time. The attenuation rate is independent and is determined by the
/// reverberation time (defined as the time in seconds for a signal to decay to
/// 1/1000, or 60dB down from its original amplitude).  Output will begin to
/// appear immediately.
///
open class AKFlatFrequencyResponseReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKFlatFrequencyResponseReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "alps")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Lower and upper bounds for Reverb Duration
    public static let reverbDurationRange: ClosedRange<Double> = 0 ... 10

    /// Initial value for Reverb Duration
    public static let defaultReverbDuration: Double = 0.5

    /// Initial value for Loop Duration
    public static let defaultLoopDuration: Double = 0.1

    /// The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    @objc open var reverbDuration: Double = defaultReverbDuration {
        willSet {
            let clampedValue = AKFlatFrequencyResponseReverb.reverbDurationRange.clamp(newValue)
            guard reverbDuration != clampedValue else { return }
            internalAU?.reverbDuration.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - reverbDuration: The duration in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude.
    ///   - loopDuration: The loop duration of the filter, in seconds. This can also be thought of as the delay time or “echo density” of the reverberation.
    ///
    public init(
        _ input: AKNode? = nil,
        reverbDuration: Double = defaultReverbDuration,
        loopDuration: Double = defaultLoopDuration
        ) {
        super.init(avAudioNode: AVAudioNode())

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.reverbDuration = reverbDuration
            self.internalAU?.setLoopDuration(Float(loopDuration))
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
