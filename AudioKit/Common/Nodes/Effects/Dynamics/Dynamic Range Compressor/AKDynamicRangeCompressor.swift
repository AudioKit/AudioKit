//
//  AKDynamicRangeCompressor.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Dynamic range compressor from Faust
///
open class AKDynamicRangeCompressor: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKDynamicRangeCompressorAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "cpsr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var ratioParameter: AUParameter?
    fileprivate var thresholdParameter: AUParameter?
    fileprivate var attackTimeParameter: AUParameter?
    fileprivate var releaseTimeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = rampTime
        }
    }

    /// Ratio to compress with, a value > 1 will compress
    open dynamic var ratio: Double = 1 {
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
    open dynamic var threshold: Double = 0.0 {
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
    open dynamic var attackTime: Double = 0.1 {
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
    open dynamic var releaseTime: Double = 0.1 {
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
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
    public init(
        _ input: AKNode?,
        ratio: Double = 1,
        threshold: Double = 0.0,
        attackTime: Double = 0.1,
        releaseTime: Double = 0.1) {

        self.ratio = ratio
        self.threshold = threshold
        self.attackTime = attackTime
        self.releaseTime = releaseTime

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        ratioParameter = tree["ratio"]
        thresholdParameter = tree["threshold"]
        attackTimeParameter = tree["attackTime"]
        releaseTimeParameter = tree["releaseTime"]

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
                }
            }
        })

        internalAU?.ratio = Float(ratio)
        internalAU?.threshold = Float(threshold)
        internalAU?.attackTime = Float(attackTime)
        internalAU?.releaseTime = Float(releaseTime)
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
