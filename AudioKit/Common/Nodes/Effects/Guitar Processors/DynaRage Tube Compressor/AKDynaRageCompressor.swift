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
    private var token: AUParameterObserverToken?

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
            if ratio != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        ratioParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.ratio = Float(newValue)
                }
            }
        }
    }

    /// Threshold (in dB) 0 = max
    @objc open dynamic var threshold: Double = 0.0 {
        willSet {
            if threshold != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        thresholdParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.threshold = Float(newValue)
                }
            }
        }
    }

    /// Attack dration
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.attackDuration = Float(newValue)
                }
            }
        }
    }

    /// Release duration
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.releaseDuration = Float(newValue)
                }
            }
        }
    }

    /// Rage Amount
    @objc open dynamic var rage: Double = 0.1 {
        willSet {
            if rage != newValue {
                if internalAU?.isSetUp ?? false {
                    if let existingToken = token {
                        rageParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.rage = Float(newValue)
                }
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

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.ratioParameter?.address {
                    self?.ratio = Double(value)
                } else if address == self?.thresholdParameter?.address {
                    self?.threshold = Double(value)
                } else if address == self?.attackDurationParameter?.address {
                    self?.attackDuration = Double(value)
                } else if address == self?.releaseDurationParameter?.address {
                    self?.releaseDuration = Double(value)
                } else if address == self?.rageParameter?.address {
                    self?.rage = Double(value)
                }
            }
        })

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
