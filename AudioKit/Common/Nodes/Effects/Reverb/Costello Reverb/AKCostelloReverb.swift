//
//  AKCostelloReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
/// modeling scattering junction of 8 lossless waveguides of equal
/// characteristic impedance.
///
open class AKCostelloReverb: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKCostelloReverbAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "rvsc")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?

    fileprivate var feedbackParameter: AUParameter?
    fileprivate var cutoffFrequencyParameter: AUParameter?

    /// Lower and upper bounds for Feedback
    public static let feedbackRange = 0.0 ... 1.0

    /// Lower and upper bounds for Cutoff Frequency
    public static let cutoffFrequencyRange = 12.0 ... 20_000.0

    /// Initial value for Feedback
    public static let defaultFeedback = 0.6

    /// Initial value for Cutoff Frequency
    public static let defaultCutoffFrequency = 4_000.0

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a
    /// large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
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

    /// Low-pass cutoff frequency.
    @objc open dynamic var cutoffFrequency: Double = defaultCutoffFrequency {
        willSet {
            guard cutoffFrequency != newValue else { return }
            if internalAU?.isSetUp == true {
                cutoffFrequencyParameter?.value = AUValue(newValue)
                return
            }
                
            internalAU?.setParameterImmediately(.cutoffFrequency, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - feedback: Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall,
    ///               and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will
    ///               make the opcode unstable.
    ///   - cutoffFrequency: Low-pass cutoff frequency.
    ///
    @objc public init(
        _ input: AKNode? = nil,
        feedback: Double = defaultFeedback,
        cutoffFrequency: Double = defaultCutoffFrequency
        ) {

        self.feedback = feedback
        self.cutoffFrequency = cutoffFrequency

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

        feedbackParameter = tree["feedback"]
        cutoffFrequencyParameter = tree["cutoffFrequency"]

        internalAU?.setParameterImmediately(.feedback, value: feedback)
        internalAU?.setParameterImmediately(.cutoffFrequency, value: cutoffFrequency)
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
