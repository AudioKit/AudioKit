// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBoosterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "bstr")

    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Amplification Factor
    open var gain: Double = 1 {
        didSet {
            leftGain = gain
            rightGain = gain
        }
    }

    /// Left Channel Amplification Factor
    open var leftGain: Double = 1 {
        willSet {
            let clampedValue = (0.0 ... 2.0).clamp(newValue)
            guard leftGain != clampedValue else { return }
            internalAU?.leftGain.value = AUValue(clampedValue)
        }
    }

    /// Right Channel Amplification Factor
    open var rightGain: Double = 1 {
        willSet {
            let clampedValue = (0.0 ... 2.0).clamp(newValue)
            guard rightGain != clampedValue else { return }
            internalAU?.rightGain.value = AUValue(clampedValue)
        }
    }

    open var rampType: AKSettings.RampType = .linear {
        willSet {
            guard rampType != newValue else { return }
            internalAU?.rampType.value = AUValue(newValue.rawValue)
        }
    }

    /// Amplification Factor in db
    open var dB: Double {
        set { gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(gain) }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    @objc public init(
        _ input: AKNode? = nil,
        gain: Double = 1
    ) {
        super.init()

        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)

            self.leftGain = gain
            self.rightGain = gain
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
