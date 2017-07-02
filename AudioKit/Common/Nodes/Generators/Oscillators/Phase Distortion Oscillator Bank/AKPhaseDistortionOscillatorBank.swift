//
//  AKPhaseDistortionOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Phase Distortion Oscillator Bank
///
open class AKPhaseDistortionOscillatorBank: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKPhaseDistortionOscillatorBankAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(instrument: "phdb")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var waveform: AKTable?
    fileprivate var phaseDistortionParameter: AUParameter?

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

    /// Duty cycle width (range -1 - 1).
    open dynamic var phaseDistortion: Double = 0.0 {
        willSet {
            if phaseDistortion != newValue {
                if internalAU?.isSetUp() ?? false {
                    if let existingToken = token {
                        phaseDistortionParameter?.setValue(Float(newValue), originator: existingToken)
                    }
                } else {
                    internalAU?.phaseDistortion = Float(newValue)
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
        self.init(waveform: AKTable(.sine))
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform:  The waveform of oscillation
    ///   - phaseDistortion: Phase distortion amount (range -1 - 1).
    ///   - attackDuration: Attack time
    ///   - decayDuration: Decay time
    ///   - sustainLevel: Sustain Level
    ///   - releaseDuration: Release time
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable,
        phaseDistortion: Double = 0.0,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1) {

        self.waveform = waveform
        self.phaseDistortion = phaseDistortion

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

            self?.internalAU?.setupWaveform(Int32(waveform.count))
            for (i, sample) in waveform.enumerated() {
                self?.internalAU?.setWaveformValue(sample, at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else {
            return
        }

        phaseDistortionParameter = tree["phaseDistortion"]

        attackDurationParameter = tree["attackDuration"]
        decayDurationParameter = tree["decayDuration"]
        sustainLevelParameter = tree["sustainLevel"]
        releaseDurationParameter = tree["releaseDuration"]
        detuningOffsetParameter = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.phaseDistortionParameter?.address {
                    self?.phaseDistortion = Double(value)
                } else if address == self?.attackDurationParameter?.address {
                    self?.attackDuration = Double(value)
                } else if address == self?.decayDurationParameter?.address {
                    self?.decayDuration = Double(value)
                } else if address == self?.sustainLevelParameter?.address {
                    self?.sustainLevel = Double(value)
                } else if address == self?.releaseDurationParameter?.address {
                    self?.releaseDuration = Double(value)
                } else if address == self?.detuningOffsetParameter?.address {
                    self?.detuningOffset = Double(value)
                } else if address == self?.detuningMultiplierParameter?.address {
                    self?.detuningMultiplier = Double(value)
                }
            }
        })

        internalAU?.phaseDistortion = Float(phaseDistortion)

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
