//
//  AKVariableDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// A delay line with cubic interpolation.
///
/// - Parameters:
///   - input: Input node to process
///   - time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
///   - feedback: Feedback amount. Should be a value between 0-1.
///   - maximumDelayTime: The maximum delay time, in seconds.
///
open class AKVariableDelay: AKNode, AKToggleable, AKComponent {
    static let ComponentDescription = AudioComponentDescription(effect: "vdla")

    // MARK: - Properties

    internal var internalAU: AKVariableDelayAudioUnit?
    internal var token: AUParameterObserverToken?

    fileprivate var timeParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
    open var time: Double = 1 {
        willSet {
            if time != newValue {
                if internalAU!.isSetUp() {
                    timeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.time = Float(newValue)
                }
            }
        }
    }
    /// Feedback amount. Should be a value between 0-1.
    open var feedback: Double = 0 {
        willSet {
            if feedback != newValue {
                if internalAU!.isSetUp() {
                    feedbackParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.feedback = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: AKNode,
        time: Double = 1,
        feedback: Double = 0,
        maximumDelayTime: Double = 5) {

        self.time = time
        self.feedback = feedback

        _Self.register(AKVariableDelayAudioUnit.self)
        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKVariableDelayAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        timeParameter     = tree["time"]
        feedbackParameter = tree["feedback"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.timeParameter!.address {
                    self.time = Double(value)
                } else if address == self.feedbackParameter!.address {
                    self.feedback = Double(value)
                }
            }
        })
        internalAU?.time = Float(time)
        internalAU?.feedback = Float(feedback)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
