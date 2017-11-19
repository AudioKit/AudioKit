//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBoosterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "gain")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var leftGainParameter: AUParameter?
    fileprivate var rightGainParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    @objc open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    fileprivate var lastKnownLeftGain: Double = 1.0
    fileprivate var lastKnownRightGain: Double = 1.0

    /// Amplification Factor
    @objc open dynamic var gain: Double = 1 {
        willSet {
            if gain == newValue {
                return
            }

            // ensure that the parameters aren't nil,
            // if they are we're using this class directly inline as an AKNode
            if internalAU?.isSetUp() ?? false {
                if token != nil && leftGainParameter != nil && rightGainParameter != nil {
                    leftGainParameter?.setValue(Float(newValue), originator: token!)
                    rightGainParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            // this means it's direct inline
            internalAU?.leftGain = Float(newValue)
            internalAU?.rightGain = Float(newValue)
        }
    }

    /// Left Channel Amplification Factor
    @objc open dynamic var leftGain: Double = 1 {
        willSet {
            if leftGain == newValue {
                return
            }

            if internalAU?.isSetUp() ?? false {
                if token != nil && leftGainParameter != nil {
                    leftGainParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.leftGain = Float(newValue)
        }
    }

    /// Right Channel Amplification Factor
    @objc open dynamic var rightGain: Double = 1 {
        willSet {
            if rightGain == newValue {
                return
            }

            if internalAU?.isSetUp() ?? false {
                if token != nil && rightGainParameter != nil {
                    rightGainParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            internalAU?.rightGain = Float(newValue)
        }
    }

    /// Amplification Factor in db
    @objc open dynamic var dB: Double {
        set {
            gain = pow(10.0, Double(newValue / 20))
        }
        get {
            return 20.0 * log10(gain)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
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
        gain: Double = 1) {

        self.leftGain = gain
        self.rightGain = gain

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

        leftGainParameter = tree["leftGain"]
        rightGainParameter = tree["rightGain"]

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
        internalAU?.leftGain = Float(gain)
        internalAU?.rightGain = Float(gain)

    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        AKLog("start() \(isStopped)")
        if isStopped {
            leftGain = lastKnownLeftGain
            rightGain = lastKnownRightGain
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        AKLog("stop() \(isPlaying)")

        if isPlaying {
            lastKnownLeftGain = leftGain
            lastKnownRightGain = rightGain
            leftGain = 1
            rightGain = 1
        }
    }
}
