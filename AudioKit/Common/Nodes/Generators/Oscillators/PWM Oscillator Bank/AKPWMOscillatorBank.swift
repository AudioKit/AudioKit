//
//  AKPWMOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Pulse-Width Modulating Oscillator Bank
///
open class AKPWMOscillatorBank: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKPWMOscillatorBankAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "pwmb")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var pulseWidthParameter: AUParameter?
    fileprivate var attackDurationParameter: AUParameter?
    fileprivate var decayDurationParameter: AUParameter?
    fileprivate var sustainLevelParameter: AUParameter?
    fileprivate var releaseDurationParameter: AUParameter?
    fileprivate var detuningOffsetParameter: AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open dynamic var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Duty cycle width (range 0-1).
    open dynamic var pulseWidth: Double = 0.5 {
        willSet {
            if pulseWidth != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        pulseWidthParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.pulseWidth = Float(newValue)
                }
            }
        }
    }

    /// Attack time
    open dynamic var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        attackDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.attackDuration = Float(newValue)
                }
            }
        }
    }
    /// Decay time
    open dynamic var decayDuration: Double = 0.1 {
        willSet {
            if decayDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        decayDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.decayDuration = Float(newValue)
                }
            }
        }
    }
    /// Sustain Level
    open dynamic var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        sustainLevelParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.sustainLevel = Float(newValue)
                }
            }
        }
    }
    /// Release time
    open dynamic var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        releaseDurationParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.releaseDuration = Float(newValue)
                }
            }
        }
    }

    /// Frequency offset in Hz.
    open dynamic var detuningOffset: Double = 0 {
        willSet {
            if detuningOffset != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        detuningOffsetParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.detuningOffset = Float(newValue)
                }
            }
        }
    }

    /// Frequency detuning multiplier
    open dynamic var detuningMultiplier: Double = 1 {
        willSet {
            if detuningMultiplier != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        detuningMultiplierParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.detuningMultiplier = Float(newValue)
                }
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(pulseWidth: 0.5)
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - pulseWidth: Duty cycle width (range 0-1).
    ///   - attackDuration: Attack time
    ///   - decayDuration: Decay time
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release time
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        pulseWidth: Double = 0.5,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1) {

        self.pulseWidth = pulseWidth
        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        pulseWidthParameter = tree["pulseWidth"]
        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            guard let _ = self else { return } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
        internalAU?.pulseWidth = Float(pulseWidth)
        internalAU?.attackDuration = Float(attackDuration)
        internalAU?.decayDuration = Float(decayDuration)
        internalAU?.sustainLevel = Float(sustainLevel)
        internalAU?.releaseDuration = Float(releaseDuration)
        internalAU?.detuningOffset = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    // MARK: - AKPolyphonic

    // Function to start, play, or activate the node at frequency
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: Double) {
        internalAU?.startNote(noteNumber, velocity: velocity, frequency: Float(frequency))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        internalAU?.stopNote(noteNumber)
    }
}
