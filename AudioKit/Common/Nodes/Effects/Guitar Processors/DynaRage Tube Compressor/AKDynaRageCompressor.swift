//
//  AKDynaRageCompressor.swift
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// DynaRage Tube Compressor | Based on DynaRage Tube Compressor RE for Reason
/// by Devoloop Srls
///

open class AKDynaRageCompressor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKDynaRageCompressorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "dldr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    // Compressor Processor
    fileprivate var ratioParameter: AUParameter?
    fileprivate var thresholdParameter: AUParameter?
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    // Rage Processor
    fileprivate var rageParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = rampDuration
        }
    }

    /// Ratio to compress with, a value > 1 will compress
    @objc open dynamic var ratio: Double = 1 {
        willSet {
            guard ratio != newValue else { return }
            if internalAU?.isSetUp == true {
                ratioParameter?.value = AUValue(newValue)
            } else {
                internalAU?.ratio = AUValue(newValue)
            }
        }
    }

    /// Threshold (in dB) 0 = max
    @objc open dynamic var threshold: Double = 0.0 {
        willSet {
            guard threshold != newValue else { return }
            if internalAU?.isSetUp == true {
                thresholdParameter?.value = AUValue(newValue)
            } else {
                internalAU?.threshold = AUValue(newValue)
            }
        }
    }

    /// Attack dration
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            guard attackDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                attackDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.attackDuration = AUValue(newValue)
            }
        }
    }

    /// Release duration
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            guard releaseDuration != newValue else { return }
            if internalAU?.isSetUp == true {
                releaseDurationParameter?.value = AUValue(newValue)
            } else {
                internalAU?.releaseDuration = AUValue(newValue)
            }
        }
    }

    /// Rage Amount
    @objc open dynamic var rage: Double = 0.1 {
        willSet {
            guard rage != newValue else { return }
            if internalAU?.isSetUp == true {
                rageParameter?.value = AUValue(newValue)
            } else {
                internalAU?.rage = AUValue(newValue)
            }
        }
    }

    /// Rage ON/OFF Switch
    @objc open dynamic var rageIsOn: Bool = true {
        willSet {
            internalAU?.rageIsOn = newValue
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
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
        rageIsOn: Bool = true) {

        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration
        self.rage = rage
        self.rageIsOn = rageIsOn

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        ratioParameter = tree["ratio"]
        thresholdParameter = tree["threshold"]
        attackDurationParameter = tree["attackDuration"]
        releaseDurationParameter = tree["releaseDuration"]
        rageParameter = tree["rage"]

        internalAU?.ratio = Float(ratio)
        internalAU?.threshold = Float(threshold)
        internalAU?.attackDuration = Float(attackDuration)
        internalAU?.releaseDuration = Float(releaseDuration)
        internalAU?.rage = Float(rage)
        internalAU?.rageIsOn = Bool(rageIsOn)
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
