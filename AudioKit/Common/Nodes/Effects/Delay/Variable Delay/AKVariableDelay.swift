//
//  AKVariableDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// A delay line with cubic interpolation.
///
open class AKVariableDelay: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKVariableDelayAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "vdla")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var timeParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Lower and upper bounds for Time
    public static let timeRange = 0.0 ... 10.0

    /// Lower and upper bounds for Feedback
    public static let feedbackRange = 0.0 ... 1.0

    /// Initial value for Time
    public static let defaultTime = 0.0

    /// Initial value for Feedback
    public static let defaultFeedback = 0.0

    /// Initial value for Maximum Delay Time
    public static let defaultMaximumDelayTime = 5.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Delay time (in seconds) This value must not exceed the maximum delay time.
    @objc open dynamic var time: Double = defaultTime {
        willSet {
            guard time != newValue else { return }
            if internalAU?.isSetUp == true {
                timeParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.time, value: newValue)
        }
    }

    /// Feedback amount. Should be a value between 0-1.
    @objc open dynamic var feedback: Double = defaultFeedback {
        willSet {
            guard feedback != newValue else { return }
            if internalAU?.isSetUp == true {
                feedbackParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.feedback, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        time: Double = defaultTime,
        feedback: Double = defaultFeedback,
        maximumDelayTime: Double = defaultMaximumDelayTime
        ) {

        self.time = time
        self.feedback = feedback

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

        timeParameter = tree["time"]
        feedbackParameter = tree["feedback"]

        internalAU?.setParameterImmediately(.time, value: time)
        internalAU?.setParameterImmediately(.feedback, value: feedback)
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

    @objc open func clear() {
        internalAU?.clear()
    }
}
