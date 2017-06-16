//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKBoosterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "gain")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var leftGainParameter: AUParameter?
    fileprivate var rightGainParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    fileprivate var lastKnownLeftGain: Double = 1.0
    fileprivate var lastKnownRightGain: Double = 1.0

    /// Amplification Factor
    open dynamic var gain: Double = 1 {
        willSet {
            if gain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        leftGainParameter?.setValue(Float(newValue), originator: existingToken)
                        rightGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.leftGain = Float(newValue)
                    internalAU?.rightGain = Float(newValue)
                }
            }
        }
    }

    /// Left Channel Amplification Factor
    open dynamic var leftGain: Double = 1 {
        willSet {
            if leftGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        leftGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.leftGain = Float(newValue)
                }
            }
        }
    }

    /// Right Channel Amplification Factor
    open dynamic var rightGain: Double = 1 {
        willSet {
            if rightGain != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        rightGainParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.rightGain = Float(newValue)
                }
            }
        }
    }

    /// Amplification Factor in db
    open dynamic var dB: Double {
        set {
            gain = pow(10.0, Double(newValue / 20))
        }
        get {
            return 20.0 * log10(gain)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this gainner node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    public init(
        _ input: AKNode?,
        gain: Double = 1) {

        self.leftGain = gain
        self.rightGain = gain

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

        leftGainParameter = tree["leftGain"]
        rightGainParameter = tree["rightGain"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.leftGainParameter?.address {
                    self?.leftGain = Double(value)
                } else if address == self?.rightGainParameter?.address {
                    self?.rightGain = Double(value)
                }
            }
        })
        internalAU?.leftGain = Float(gain)
        internalAU?.rightGain = Float(gain)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            leftGain = lastKnownLeftGain
            rightGain = lastKnownRightGain
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownLeftGain = leftGain
            lastKnownRightGain = rightGain
            leftGain = 1
            rightGain = 1
        }
    }
}
