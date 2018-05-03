//
//  AKAmplitudeEnvelope.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Triggerable classic ADSR envelope
///
open class AKAmplitudeEnvelope: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKAmplitudeEnvelopeAudioUnit

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "adsr")

    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// Attack Duration in seconds
    @objc open dynamic var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.attackDuration, value: newValue)
        }
    }

    /// Decay Duration in seconds
    @objc open dynamic var decayDuration: Double = 0.1 {
        willSet {
            if decayDuration == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    decayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.decayDuration, value: newValue)
        }
    }

    /// Sustain Level
    @objc open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    sustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.sustainLevel, value: newValue)
        }
    }

    /// Release Duration in seconds
    @objc open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration == newValue {
                return
            }
            if internalAU?.isSetUp ?? false {
                if let existingToken = token {
                    releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    return
                }
            }
            internalAU?.setParameterImmediately(.releaseDuration, value: newValue)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted: Bool {
        return internalAU?.isPlaying ?? false
    }

    // MARK: - Initialization

    /// Initialize this envelope node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - attackDuration: Attack Duration in seconds
    ///   - decayDuration: Decay Duration in seconds
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release Duration in seconds
    ///
    @objc public init(
        _ input: AKNode? = nil,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1
    ) {

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration

        _Self.register()
        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: strongSelf)
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })

       internalAU?.setParameterImmediately(.attackDuration, value: attackDuration)
        internalAU?.setParameterImmediately(.decayDuration, value: decayDuration)
        internalAU?.setParameterImmediately(.sustainLevel, value: sustainLevel)
        internalAU?.setParameterImmediately(.releaseDuration, value: releaseDuration)
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
