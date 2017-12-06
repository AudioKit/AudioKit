//
//  AKDynaRageCompressor.swift
//  AudioKit
//
//  Created by Mike Gazzaruso, revision history on Github.
//  Copyright © 2017 Mike Gazzaruso, Devoloop Srls. All rights reserved.
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
    fileprivate var attackTimeParameter: AUParameter?
    fileprivate var releaseTimeParameter: AUParameter?

    // Rage Processor
    fileprivate var rageAmountParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Ratio to compress with, a value > 1 will compress
    @objc open dynamic var ratio: Double = 1 {
        willSet {
            if ratio != newValue {
                if internalAU?.isSetUp() ?? false {
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
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        thresholdParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.threshold = Float(newValue)
                }
            }
        }
    }

    /// Attack time
    @objc open dynamic var attackTime: Double = 0.1 {
        willSet {
            if attackTime != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        attackTimeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.attackTime = Float(newValue)
                }
            }
        }
    }

    /// Release time
    @objc open dynamic var releaseTime: Double = 0.1 {
        willSet {
            if releaseTime != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        releaseTimeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.releaseTime = Float(newValue)
                }
            }
        }
    }

    /// Rage Amount
    @objc open dynamic var rageAmount: Double = 0.1 {
        willSet {
            if rageAmount != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        rageAmountParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.rageAmount = Float(newValue)
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
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this compressor node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - ratio: Ratio to compress with, a value > 1 will compress
    ///   - threshold: Threshold (in dB) 0 = max
    ///   - attackTime: Attack time
    ///   - releaseTime: Release time
    ///
    @objc public init(
        _ input: AKNode? = nil,
        ratio: Double = 1,
        threshold: Double = 0.0,
        attackTime: Double = 0.1,
        releaseTime: Double = 0.1,
        rageAmount: Double = 0.1,
        rageIsOn: Bool = true) {

        self.ratio = ratio
        self.threshold = threshold
        self.attackTime = attackTime
        self.releaseTime = releaseTime
        self.rageAmount = rageAmount
        self.rageIsOn = rageIsOn

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        ratioParameter = tree["ratio"]
        thresholdParameter = tree["threshold"]
        attackTimeParameter = tree["attackTime"]
        releaseTimeParameter = tree["releaseTime"]
        rageAmountParameter = tree["rageAmount"]

        token = tree.token(byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.ratioParameter?.address {
                    self?.ratio = Double(value)
                } else if address == self?.thresholdParameter?.address {
                    self?.threshold = Double(value)
                } else if address == self?.attackTimeParameter?.address {
                    self?.attackTime = Double(value)
                } else if address == self?.releaseTimeParameter?.address {
                    self?.releaseTime = Double(value)
                } else if address == self?.rageAmountParameter?.address {
                    self?.rageAmount = Double(value)
                }
            }
        })

        internalAU?.ratio = Float(ratio)
        internalAU?.threshold = Float(threshold)
        internalAU?.attackTime = Float(attackTime)
        internalAU?.releaseTime = Float(releaseTime)
        internalAU?.rageAmount = Float(rageAmount)
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
