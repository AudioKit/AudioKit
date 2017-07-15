//
//  AKStringResonator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// AKStringResonator passes the input through a network composed of comb,
/// low-pass and all-pass filters, similar to the one used in some versions of
/// the Karplus-Strong algorithm, creating a string resonator effect. The
/// fundamental frequency of the “string” is controlled by the
/// fundamentalFrequency.  This operation can be used to simulate sympathetic
/// resonances to an input signal.
///
open class AKStringResonator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKStringResonatorAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "stre")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var fundamentalFrequencyParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Fundamental frequency of string.
    open dynamic var fundamentalFrequency: Double = 100 {
        willSet {
            if fundamentalFrequency != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        fundamentalFrequencyParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.fundamentalFrequency = Float(newValue)
                }
            }
        }
    }
    /// Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance.
    /// Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    open dynamic var feedback: Double = 0.95 {
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

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - fundamentalFrequency: Fundamental frequency of string.
    ///   - feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more
    ///               pronounced resonance. Small values may leave the input signal unaffected. Depending on the
    ///               filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode?,
        fundamentalFrequency: Double = 100,
        feedback: Double = 0.95) {

        self.fundamentalFrequency = fundamentalFrequency
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

        fundamentalFrequencyParameter = tree["fundamentalFrequency"]
        feedbackParameter = tree["feedback"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

        internalAU?.fundamentalFrequency = Float(fundamentalFrequency)
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
