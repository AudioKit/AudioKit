//
//  AKVariableDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// A delay line with cubic interpolation.
///
open class AKVariableDelay: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKVariableDelayAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "vdla")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var timeParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Delay time (in seconds) that can be changed at any point. This value must not exceed the maximum delay time.
    open dynamic var time: Double = 1 {
        willSet {
            if time != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        timeParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.time = Float(newValue)
                }
            }
        }
    }
    /// Feedback amount. Should be a value between 0-1.
    open dynamic var feedback: Double = 0 {
        willSet {
            if feedback != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        feedbackParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.feedback = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open dynamic var isStarted: Bool {
        return internalAU?.isPlaying() ?? false
    }

    // MARK: - Initialization

    /// Initialize this delay node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - time: Delay time (in seconds). This value must not exceed the maximum delay time.
    ///   - feedback: Feedback amount. Should be a value between 0-1.
    ///   - maximumDelayTime: The maximum delay time, in seconds.
    ///
    public init(
        _ input: AKNode?,
        time: Double = 1,
        feedback: Double = 0,
        maximumDelayTime: Double = 5) {

        self.time = time
        self.feedback = feedback

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

        timeParameter = tree["time"]
        feedbackParameter = tree["feedback"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.timeParameter?.address {
                    self?.time = Double(value)
                } else if address == self?.feedbackParameter?.address {
                    self?.feedback = Double(value)
                }
            }
        })
        internalAU?.time = Float(time)
        internalAU?.feedback = Float(feedback)
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
