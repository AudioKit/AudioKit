//
//  AKCostelloReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// 8 delay line stereo FDN reverb, with feedback matrix based upon physical
/// modeling scattering junction of 8 lossless waveguides of equal
/// characteristic impedance.
///
open class AKCostelloReverb: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKCostelloReverbAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "rvsc")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var feedbackParameter: AUParameter?
    fileprivate var cutoffFrequencyParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    open var feedback: Double = 0.6 {
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
    /// Low-pass cutoff frequency.
    open var cutoffFrequency: Double = 4_000 {
        willSet {
            if cutoffFrequency != newValue {
                if internalAU!.isSetUp() {
                    cutoffFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.cutoffFrequency = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this reverb node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - feedback: Feedback level in the range 0 to 1. 0.6 gives a good small 'live' room sound, 0.8 a small hall, and 0.9 a large hall. A setting of exactly 1 means infinite length, while higher values will make the opcode unstable.
    ///   - cutoffFrequency: Low-pass cutoff frequency.
    ///
    public init(
        _ input: AKNode,
        feedback: Double = 0.6,
        cutoffFrequency: Double = 4_000) {

        self.feedback = feedback
        self.cutoffFrequency = cutoffFrequency

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        feedbackParameter = tree["feedback"]
        cutoffFrequencyParameter = tree["cutoffFrequency"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.feedbackParameter!.address {
                    self?.feedback = Double(value)
                } else if address == self?.cutoffFrequencyParameter!.address {
                    self?.cutoffFrequency = Double(value)
                }
            }
        })

        internalAU?.feedback = Float(feedback)
        internalAU?.cutoffFrequency = Float(cutoffFrequency)
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
