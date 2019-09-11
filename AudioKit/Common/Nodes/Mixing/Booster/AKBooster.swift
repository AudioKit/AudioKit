//
//  AKBooster.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Stereo Booster
///
open class AKBooster: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {
    public typealias AKAudioUnitType = AKBoosterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "bstr")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    fileprivate var leftGainParameter: AUParameter?
    fileprivate var rightGainParameter: AUParameter?

    private var _parameterAutomation: AKParameterAutomation?
    public var parameterAutomation: AKParameterAutomation? {
        return self._parameterAutomation
    }

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    @objc open dynamic var rampType: AKSettings.RampType = .linear {
        willSet {
            internalAU?.rampType = newValue.rawValue
        }
    }

    fileprivate var lastKnownLeftGain: Double = 1.0
    fileprivate var lastKnownRightGain: Double = 1.0

    /// Amplification Factor
    @objc open dynamic var gain: Double = 1 {
        willSet {
            // this might not actually be true as the parameters can be altered by automation
//            guard gain != newValue else {
//                AKLog("Value hasn't changed")
//                return
//            }

            // ensure that the parameters aren't nil,
            // if they are we're using this class directly inline as an AKNode
            if internalAU?.isSetUp == true {
                leftGainParameter?.value = AUValue(newValue)
                rightGainParameter?.value = AUValue(newValue)
                return
            }

            // this means it's direct inline
            internalAU?.setParameterImmediately(.leftGain, value: newValue)
            internalAU?.setParameterImmediately(.rightGain, value: newValue)
        }
    }

    /// Left Channel Amplification Factor
    @objc open dynamic var leftGain: Double = 1 {
        willSet {
            // this might not actually be true as the parameters can be altered by automation
            //guard leftGain != newValue else { return }
            if internalAU?.isSetUp == true {
                leftGainParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.leftGain, value: newValue)
        }
    }

    /// Right Channel Amplification Factor
    @objc open dynamic var rightGain: Double = 1 {
        willSet {
            // this might not actually be true as the parameters can be altered by automation
            //guard rightGain != newValue else { return }
            if internalAU?.isSetUp == true {
                rightGainParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.rightGain, value: newValue)
        }
    }

    /// Amplification Factor in db
    @objc open dynamic var dB: Double {
        set { self.gain = pow(10.0, newValue / 20.0) }
        get { return 20.0 * log10(self.gain) }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return self.internalAU?.isPlaying ?? false
    }

    @objc open var lastRenderTime: AUEventSampleTime {
        return self.internalAU?.lastRenderTime ?? 0
    }

    // MARK: - Initialization

    /// Initialize this booster node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    @objc public init(_ input: AKNode? = nil,
                      gain: Double = 1) {
        self.leftGain = gain
        self.rightGain = gain

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

        self.leftGainParameter = tree["leftGain"]
        self.rightGainParameter = tree["rightGain"]

        self.internalAU?.setParameterImmediately(.leftGain, value: gain)
        self.internalAU?.setParameterImmediately(.rightGain, value: gain)
        self.internalAU?.setParameterImmediately(.rampDuration, value: self.rampDuration)
        self.internalAU?.rampType = self.rampType.rawValue

        if let internalAU = internalAU, let avAudioUnit = avAudioUnit {
            self._parameterAutomation = AKParameterAutomation(internalAU, avAudioUnit: avAudioUnit)
        }
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            self.leftGain = lastKnownLeftGain
            self.rightGain = self.lastKnownRightGain
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            self.lastKnownLeftGain = leftGain
            self.lastKnownRightGain = rightGain
            self.leftGain = 1
            self.rightGain = 1
        }
    }

    open override func detach() {
        super.detach()
        self.parameterAutomation?.dispose()
        self._parameterAutomation = nil
    }

    // MARK: - AKAutomatable
    public func startAutomation(at audioTime: AVAudioTime?, duration: AVAudioTime?) {
        self.parameterAutomation?.start(at: audioTime, duration: duration)
    }

    public func stopAutomation() {
        self.parameterAutomation?.stop()
    }

    /// Convenience function for adding a pair of points for both left and right addresses
    public func addAutomationPoint(value: Double,
                                   at sampleTime: AUEventSampleTime,
                                   anchorTime: AUEventSampleTime,
                                   rampDuration: AUAudioFrameCount = 0,
                                   rampType: AKSettings.RampType = .linear) {
        guard let leftAddress = leftGainParameter?.address,
            let rightAddress = rightGainParameter?.address else {
            AKLog("Param addresses aren't valid")
            return
        }

        self.parameterAutomation?.addPoint(leftAddress, value: AUValue(value), sampleTime: sampleTime, anchorTime: anchorTime, rampDuration: rampDuration)
        self.parameterAutomation?.addPoint(rightAddress, value: AUValue(value), sampleTime: sampleTime, anchorTime: anchorTime, rampDuration: rampDuration)
    }
}
