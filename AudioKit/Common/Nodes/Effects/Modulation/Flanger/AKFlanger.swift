// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Flanger
///
open class AKFlanger: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKFlangerAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "flgr")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    public static let frequencyRange = Double(kAKFlanger_MinFrequency) ... Double(kAKFlanger_MaxFrequency)
    public static let depthRange = Double(kAKFlanger_MinDepth) ... Double(kAKFlanger_MaxDepth)
    public static let feedbackRange = Double(kAKFlanger_MinFeedback) ... Double(kAKFlanger_MaxFeedback)
    public static let dryWetMixRange = Double(kAKFlanger_MinDryWetMix) ... Double(kAKFlanger_MaxDryWetMix)

    public static let defaultFrequency = Double(kAKFlanger_DefaultFrequency)
    public static let defaultDepth = Double(kAKFlanger_DefaultDepth)
    public static let defaultFeedback = Double(kAKFlanger_DefaultFeedback)
    public static let defaultDryWetMix = Double(kAKFlanger_DefaultDryWetMix)

    /// Modulation Frequency (Hz)
    @objc open var frequency: Double = defaultFrequency {
        willSet {
            let clampedValue = AKFlanger.frequencyRange.clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = AUValue(clampedValue)
        }
    }

    /// Modulation Depth (fraction)
    @objc open var depth: Double = defaultDepth {
        willSet {
            let clampedValue = AKFlanger.depthRange.clamp(newValue)
            guard depth != clampedValue else { return }
            internalAU?.depth.value = AUValue(clampedValue)
        }
    }

    /// Feedback (fraction)
    @objc open var feedback: Double = defaultFeedback {
        willSet {
            let clampedValue = AKFlanger.feedbackRange.clamp(newValue)
            guard feedback != clampedValue else { return }
            internalAU?.feedback.value = AUValue(clampedValue)
        }
    }

    /// Dry Wet Mix (fraction)
    @objc open var dryWetMix: Double = defaultDryWetMix {
        willSet {
            let clampedValue = AKFlanger.dryWetMixRange.clamp(newValue)
            guard dryWetMix != clampedValue else { return }
            internalAU?.dryWetMix.value = AUValue(clampedValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this flanger node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be processed
    ///   - frequency: modulation frequency Hz
    ///   - depth: depth of modulation (fraction)
    ///   - feedback: feedback fraction
    ///   - dryWetMix: fraction of wet signal in mix  - traditionally 50%, avoid changing this value
    ///
    public init(
        _ input: AKNode? = nil,
        frequency: Double = defaultFrequency,
        depth: Double = defaultDepth,
        feedback: Double = defaultFeedback,
        dryWetMix: Double = defaultDryWetMix
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.frequency = frequency
            self.depth = depth
            self.feedback = feedback
            self.dryWetMix = dryWetMix
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
