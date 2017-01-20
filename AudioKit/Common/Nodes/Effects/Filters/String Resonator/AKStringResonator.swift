//
//  AKStringResonator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AKStringResonator passes the input through a network composed of comb,
/// low-pass and all-pass filters, similar to the one used in some versions of
/// the Karplus-Strong algorithm, creating a string resonator effect. The
/// fundamental frequency of the “string” is controlled by the
/// fundamentalFrequency.  This operation can be used to simulate sympathetic
/// resonances to an input signal.
///
open class AKStringResonator: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKStringResonatorAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "stre")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var fundamentalFrequencyParameter: AUParameter?
    fileprivate var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Fundamental frequency of string.
    open var fundamentalFrequency: Double = 100 {
        willSet {
            if fundamentalFrequency != newValue {
                if internalAU!.isSetUp() {
                    fundamentalFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.fundamentalFrequency = Float(newValue)
                }
            }
        }
    }
    /// Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    open var feedback: Double = 0.95 {
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

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - fundamentalFrequency: Fundamental frequency of string.
    ///   - feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode,
        fundamentalFrequency: Double = 100,
        feedback: Double = 0.95) {

        self.fundamentalFrequency = fundamentalFrequency
        self.feedback = feedback

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

        guard let tree = internalAU?.parameterTree else { return }

        fundamentalFrequencyParameter = tree["fundamentalFrequency"]
        feedbackParameter             = tree["feedback"]

        token = tree.token (byAddingParameterObserver: { [weak self]
            address, value in

            DispatchQueue.main.async {
                if address == self?.fundamentalFrequencyParameter!.address {
                    self?.fundamentalFrequency = Double(value)
                } else if address == self?.feedbackParameter!.address {
                    self?.feedback = Double(value)
                }
            }
        })

        internalAU?.fundamentalFrequency = Float(fundamentalFrequency)
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
