//
//  AKDynamicRangeCompressor.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Dynamic range compressor from Faust
///
open class AKDynamicRangeCompressor: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKDynamicRangeCompressorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "cpsr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var ratioParameter: AUParameter?
    fileprivate var thresholdParameter: AUParameter?
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    /// Lower and upper bounds for Ratio
    public static let ratioRange = 0.01 ... 100.0

    /// Lower and upper bounds for Threshold
    public static let thresholdRange = -100.0 ... 0.0

    /// Lower and upper bounds for Attack Duration
    public static let attackDurationRange = 0.0 ... 1.0

    /// Lower and upper bounds for Release Duration
    public static let releaseDurationRange = 0.0 ... 1.0

    /// Initial value for Ratio
    public static let defaultRatio = 1.0

    /// Initial value for Threshold
    public static let defaultThreshold = 0.0

    /// Initial value for Attack Duration
    public static let defaultAttackDuration = 0.1

    /// Initial value for Release Duration
    public static let defaultReleaseDuration = 0.1

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Ratio to compress with, a value > 1 will compress
    @objc open dynamic var ratio: Double = defaultRatio {
        willSet {
            if ratio == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    ratioParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.ratio, value: newValue)
        }
    }

    /// Threshold (in dB) 0 = max
    @objc open dynamic var threshold: Double = defaultThreshold {
        willSet {
            if threshold == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    thresholdParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.threshold, value: newValue)
        }
    }

    /// Attack Duration in seconds
    @objc open dynamic var attackDuration: Double = defaultAttackDuration {
        willSet {
            if attackDuration == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.attackTime, value: newValue)
        }
    }

    /// Release Duration in seconds
    @objc open dynamic var releaseDuration: Double = defaultReleaseDuration {
        willSet {
            if releaseDuration == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.releaseTime, value: newValue)
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
        ratio: Double = defaultRatio,
        threshold: Double = defaultThreshold,
        attackDuration: Double = defaultAttackDuration,
        releaseDuration: Double = defaultReleaseDuration
        ) {

        self.ratio = ratio
        self.threshold = threshold
        self.attackDuration = attackDuration
        self.releaseDuration = releaseDuration

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
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

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.setParameterImmediately(.ratio, value: ratio)
        internalAU?.setParameterImmediately(.threshold, value: threshold)
        internalAU?.setParameterImmediately(.attackTime, value: attackDuration)
        internalAU?.setParameterImmediately(.releaseTime, value: releaseDuration)
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
