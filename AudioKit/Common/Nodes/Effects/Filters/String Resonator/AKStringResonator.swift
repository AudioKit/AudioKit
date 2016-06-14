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
/// - parameter input: Input node to process
/// - parameter fundamentalFrequency: Fundamental frequency of string.
/// - parameter feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
///
public class AKStringResonator: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKStringResonatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var fundamentalFrequencyParameter: AUParameter?
    private var feedbackParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Fundamental frequency of string.
    public var fundamentalFrequency: Double = 100 {
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
    public var feedback: Double = 0.95 {
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
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter fundamentalFrequency: Fundamental frequency of string.
    /// - parameter feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode,
        fundamentalFrequency: Double = 100,
        feedback: Double = 0.95) {

        self.fundamentalFrequency = fundamentalFrequency
        self.feedback = feedback

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x73747265 /*'stre'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKStringResonatorAudioUnit.self,
            as: description,
            name: "Local AKStringResonator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.auAudioUnit as? AKStringResonatorAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        fundamentalFrequencyParameter = tree.value(forKey: "fundamentalFrequency") as? AUParameter
        feedbackParameter             = tree.value(forKey: "feedback")             as? AUParameter

        token = tree.token {
            address, value in

            DispatchQueue.main.async {
                if address == self.fundamentalFrequencyParameter!.address {
                    self.fundamentalFrequency = Double(value)
                } else if address == self.feedbackParameter!.address {
                    self.feedback = Double(value)
                }
            }
        }
        internalAU?.fundamentalFrequency = Float(fundamentalFrequency)
        internalAU?.feedback = Float(feedback)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
