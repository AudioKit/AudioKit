// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///

open class AKDynaRageCompressor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKDynaRageCompressorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dldr")

    // MARK: - Properties
    public private(set) var internalAU: AKAudioUnitType?

    /// Ratio to compress with, a value > 1 will compress
    @objc open dynamic var ratio: Double = 1 {
        willSet {
            guard ratio != newValue else { return }
            internalAU?.ratio.value = AUValue(newValue)
        }
    }

    /// Threshold (in dB) 0 = max
    @objc open dynamic var threshold: Double = 0.0 {
        willSet {
            guard threshold != newValue else { return }
            internalAU?.threshold.value = AUValue(newValue)
        }
    }

    /// Attack dration
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            guard attackDuration != newValue else { return }
            internalAU?.attack.value = AUValue(newValue)
        }
    }

    /// Release duration
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            guard releaseDuration != newValue else { return }
            internalAU?.release.value = AUValue(newValue)
        }
    }

    /// Rage Amount
    @objc open dynamic var rage: Double = 0.1 {
        willSet {
            guard rage != newValue else { return }
            internalAU?.rageAmount.value = AUValue(newValue)
        }
    }

    /// Rage ON/OFF Switch
    @objc open dynamic var rageIsOn: Bool = true {
        willSet {
            guard rageIsOn != newValue else { return }
            internalAU?.rageEnabled.value = AUValue(newValue ? 1 : 0)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackDuration: Attack duration in seconds
    ///   - releaseDuration: Release duration in seconds
    ///
    @objc public init(
        _ input: AKNode? = nil,
        ratio: Double = 1,
        threshold: Double = 0.0,
        attackDuration: Double = 0.1,
        releaseDuration: Double = 0.1,
        rage: Double = 0.1,
        rageIsOn: Bool = true
    ) {
        super.init(avAudioNode: AVAudioNode())
        
        _Self.register()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: self)
            
            self.ratio = ratio
            self.threshold = threshold
            self.attackDuration = attackDuration
            self.releaseDuration = releaseDuration
            self.rage = rage
            self.rageIsOn = rageIsOn
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
