//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Stereo Booster
///
open class AKBooster2: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKBooster2AudioUnit
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
            internalAU?.rampTime = Float(newValue)
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
            if internalAU?.isSetUp ?? false {
                if token != nil && leftGainParameter != nil && rightGainParameter != nil {
                    leftGainParameter?.setValue(Float(newValue), originator: token!)
                    rightGainParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }

            // this means it's direct inline
            internalAU?.setParamImmediate(addr: AKBoosterParameter.leftGain, value: Float(newValue))
            internalAU?.setParamImmediate(addr: AKBoosterParameter.rightGain, value: Float(newValue))
        }
    }

    /// Left Channel Amplification Factor
    @objc open dynamic var leftGain: Double = 1 {
        willSet {
            if leftGain == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && leftGainParameter != nil {
                    leftGainParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            internalAU?.setParamImmediate(addr: AKBoosterParameter.leftGain, value: Float(newValue))
        }
    }

    /// Right Channel Amplification Factor
    @objc open dynamic var rightGain: Double = 1 {
        willSet {
            if rightGain == newValue {
                return
            }

            if internalAU?.isSetUp ?? false {
                if token != nil && rightGainParameter != nil {
                    rightGainParameter?.setValue(Float(newValue), originator: token!)
                    return
                }
            }
            internalAU?.setParamImmediate(addr: AKBoosterParameter.rightGain, value: Float(newValue))
        }
    }

    /// Amplification Factor in db
    @objc open dynamic var dB: Double {
        set {
            self.gain = pow(10.0, Double(newValue / 20))
        }
        get {
            return 20.0 * log10(self.gain)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return self.internalAU?.isPlaying ?? false
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

        self.leftGain = gain
        self.rightGain = gain

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

        self.leftGainParameter = tree["leftGain"]
        self.rightGainParameter = tree["rightGain"]

        self.token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        self.internalAU?.setParamImmediate(addr: AKBoosterParameter.leftGain, value: Float(gain))
        self.internalAU?.setParamImmediate(addr: AKBoosterParameter.rightGain, value: Float(gain))
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        AKLog("start() \(isStopped)")
        if isStopped {
            self.leftGain = lastKnownLeftGain
            self.rightGain = self.lastKnownRightGain
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        AKLog("stop() \(isPlaying)")

        if isPlaying {
            self.lastKnownLeftGain = leftGain
            self.lastKnownRightGain = rightGain
            self.leftGain = 1
            self.rightGain = 1
        }
    }
}
