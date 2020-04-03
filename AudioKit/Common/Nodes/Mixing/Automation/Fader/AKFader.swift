//
//  AKFader.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2019 AudioKit. All rights reserved.
//

/// Stereo Fader. Similar to AKBooster but with the addition of
/// Automation support.
open class AKFader: AKNode, AKToggleable, AKComponent, AKInput, AKAutomatable {
    public typealias AKAudioUnitType = AKFaderAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "fder")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    private var _parameterAutomation: AKParameterAutomation?
    public var parameterAutomation: AKParameterAutomation? {
        return self._parameterAutomation
    }

    fileprivate var leftGainParameter: AUParameter?
    fileprivate var rightGainParameter: AUParameter?
    fileprivate var taperParameter: AUParameter?
    fileprivate var skewParameter: AUParameter?
    fileprivate var offsetParameter: AUParameter?

    /// Amplification Factor
    @objc open dynamic var gain: Double = 1 {
        willSet {
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
            if internalAU?.isSetUp == true {
                rightGainParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.rightGain, value: newValue)
        }
    }

    /// Amplification Factor in db
    @objc open dynamic var dB: Double {
        set {
            self.gain = pow(10.0, newValue / 20.0)
        }
        get {
            return 20.0 * log10(self.gain)
        }
    }

    /// Taper is a positive number where 1=Linear and the 0->1 and 1 and up represent curves on each side of linearity
    @objc open dynamic var taper: Double = 1 {
        willSet {
            if internalAU?.isSetUp == true {
                taperParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.taper, value: newValue)
        }
    }

    /// Skew ranges from zero to one where zero is easing In and 1 is easing Out. default 0.
    @objc open dynamic var skew: Double = 0 {
        willSet {
            if internalAU?.isSetUp == true {
                skewParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.skew, value: newValue)
        }
    }

    /// Offset allows you to start a ramp somewhere in the middle of it. default 0.
    @objc open dynamic var offset: Double = 0 {
        willSet {
            if internalAU?.isSetUp == true {
                offsetParameter?.value = AUValue(newValue)
                return
            }
            internalAU?.setParameterImmediately(.offset, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return self.internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this fader node
    ///
    /// - Parameters:
    ///   - input: AKNode whose output will be amplified
    ///   - gain: Amplification factor (Default: 1, Minimum: 0)
    ///
    @objc public init(_ input: AKNode? = nil,
                      gain: Double = 1,
                      taper: Double = 1,
                      skew: Double = 0,
                      offset: Double = 0) {
        self.leftGain = gain
        self.rightGain = gain
        self.taper = taper
        self.skew = skew
        self.offset = offset

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
        self.taperParameter = tree["taper"]
        self.skewParameter = tree["skew"]
        self.offsetParameter = tree["offset"]

        self.internalAU?.setParameterImmediately(.leftGain, value: gain)
        self.internalAU?.setParameterImmediately(.rightGain, value: gain)
        self.internalAU?.setParameterImmediately(.taper, value: taper)
        self.internalAU?.setParameterImmediately(.skew, value: skew)
        self.internalAU?.setParameterImmediately(.offset, value: offset)

        if let internalAU = internalAU, let avAudioUnit = avAudioUnit {
            self._parameterAutomation = AKParameterAutomation(internalAU, avAudioUnit: avAudioUnit)
        }
    }

    open override func detach() {
        super.detach()
        self._parameterAutomation = nil
    }

    @objc deinit {
        // AKLog("* { AKFader }")
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.shouldBypassEffect = false
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.shouldBypassEffect = true
        internalAU?.stop()
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
                                   taper taperValue: Double? = nil,
                                   skew skewValue: Double? = nil,
                                   offset offsetValue: AUAudioFrameCount? = nil) {
        guard let leftAddress = leftGainParameter?.address,
            let rightAddress = rightGainParameter?.address else {
            AKLog("Param addresses aren't valid")
            return
        }

        // if a taper value is passed in, also add a point with its address to trigger at the same time
        if let taperValue = taperValue, let taperAddress = taperParameter?.address {
            self.parameterAutomation?.addPoint(taperAddress,
                                               value: AUValue(taperValue),
                                               sampleTime: sampleTime,
                                               anchorTime: anchorTime,
                                               rampDuration: rampDuration)
        }
        // if a skew value is passed in, also add a point with its address to trigger at the same time
        if let skewValue = skewValue, let skewAddress = skewParameter?.address {
            self.parameterAutomation?.addPoint(skewAddress,
                                               value: AUValue(skewValue),
                                               sampleTime: sampleTime,
                                               anchorTime: anchorTime,
                                               rampDuration: rampDuration)
        }

        // if an offset value is passed in, also add a point with its address to trigger at the same time
        if let offsetValue = offsetValue, let offsetAddress = offsetParameter?.address {
            self.parameterAutomation?.addPoint(offsetAddress,
                                               value: AUValue(offsetValue),
                                               sampleTime: sampleTime,
                                               anchorTime: anchorTime,
                                               rampDuration: rampDuration)
        }

        self.parameterAutomation?.addPoint(leftAddress,
                                           value: AUValue(value),
                                           sampleTime: sampleTime,
                                           anchorTime: anchorTime,
                                           rampDuration: rampDuration)
        self.parameterAutomation?.addPoint(rightAddress,
                                           value: AUValue(value),
                                           sampleTime: sampleTime,
                                           anchorTime: anchorTime,
                                           rampDuration: rampDuration)
    }
}
