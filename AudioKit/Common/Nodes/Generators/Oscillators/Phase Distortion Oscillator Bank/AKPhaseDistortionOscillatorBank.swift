//
//  AKPhaseDistortionOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Phase Distortion Oscillator Bank
///
/// - Parameters:
///   - waveform:  The waveform of oscillation
///   - phaseDistortion: Duty cycle width (range 0-1).
///   - attackDuration: Attack time
///   - decayDuration: Decay time
///   - sustainLevel: Sustain Level
///   - releaseDuration: Release time
///   - detuningOffset: Frequency offset in Hz.
///   - detuningMultiplier: Frequency detuning multiplier
///
public class AKPhaseDistortionOscillatorBank: AKPolyphonicNode {

    // MARK: - Properties

    internal var internalAU: AKPhaseDistortionOscillatorBankAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveform: AKTable?
    private var phaseDistortionParameter: AUParameter?

    private var attackDurationParameter: AUParameter?
    private var decayDurationParameter: AUParameter?
    private var sustainLevelParameter: AUParameter?
    private var releaseDurationParameter: AUParameter?
    private var detuningOffsetParameter: AUParameter?
    private var detuningMultiplierParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// Duty cycle width (range -1 - 1).
    public var phaseDistortion: Double = 0.0 {
        willSet {
            if phaseDistortion != newValue {
                if internalAU!.isSetUp() {
                    phaseDistortionParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.phaseDistortion = Float(newValue)
                }
            }
        }
    }



    /// Attack time
    public var attackDuration: Double = 0.1 {
        willSet {
            if attackDuration != newValue {
                if internalAU!.isSetUp() {
                    attackDurationParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.attackDuration = Float(newValue)
                }
            }
        }
    }
    /// Decay time
    public var decayDuration: Double = 0.1 {
        willSet {
            if decayDuration != newValue {
                if internalAU!.isSetUp() {
                    decayDurationParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.decayDuration = Float(newValue)
                }
            }
        }
    }
    /// Sustain Level
    public var sustainLevel: Double = 1.0 {
        willSet {
            if sustainLevel != newValue {
                if internalAU!.isSetUp() {
                    sustainLevelParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.sustainLevel = Float(newValue)
                }
            }
        }
    }
    /// Release time
    public var releaseDuration: Double = 0.1 {
        willSet {
            if releaseDuration != newValue {
                if internalAU!.isSetUp() {
                    releaseDurationParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.releaseDuration = Float(newValue)
                }
            }
        }
    }

    /// Frequency offset in Hz.
    public var detuningOffset: Double = 0 {
        willSet {
            if detuningOffset != newValue {
                if internalAU!.isSetUp() {
                    detuningOffsetParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.detuningOffset = Float(newValue)
                }
            }
        }
    }

    /// Frequency detuning multiplier
    public var detuningMultiplier: Double = 1 {
        willSet {
            if detuningMultiplier != newValue {
                if internalAU!.isSetUp() {
                    detuningMultiplierParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.detuningMultiplier = Float(newValue)
                }
            }
        }
    }

    // MARK: - Initialization
    
    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveform: AKTable(.Sine))
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform:  The waveform of oscillation
    ///   - phaseDistortion: Duty cycle width (range 0-1).
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

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x70686462 /*'phdb'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPhaseDistortionOscillatorBankAudioUnit.self,
            as: description,
            name: "Local AKPhaseDistortionOscillatorBank",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKPhaseDistortionOscillatorBankAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for i in 0 ..< waveform.size {
                self.internalAU?.setWaveformValue(waveform.values[i], at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        phaseDistortionParameter    = tree.value(forKey: "phaseDistortion")    as? AUParameter

        attackDurationParameter     = tree.value(forKey: "attackDuration")     as? AUParameter
        decayDurationParameter      = tree.value(forKey: "decayDuration")      as? AUParameter
        sustainLevelParameter       = tree.value(forKey: "sustainLevel")       as? AUParameter
        releaseDurationParameter    = tree.value(forKey: "releaseDuration")    as? AUParameter
        detuningOffsetParameter     = tree.value(forKey: "detuningOffset")     as? AUParameter
        detuningMultiplierParameter = tree.value(forKey: "detuningMultiplier") as? AUParameter

        token = tree.token(byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
            if address == self.phaseDistortionParameter!.address {
                self.phaseDistortion = Double(value)
                } else if address == self.attackDurationParameter!.address {
                    self.attackDuration = Double(value)
                } else if address == self.decayDurationParameter!.address {
                    self.decayDuration = Double(value)
                } else if address == self.sustainLevelParameter!.address {
                    self.sustainLevel = Double(value)
                } else if address == self.releaseDurationParameter!.address {
                    self.releaseDuration = Double(value)
                } else if address == self.detuningOffsetParameter!.address {
                    self.detuningOffset = Double(value)
                } else if address == self.detuningMultiplierParameter!.address {
                    self.detuningMultiplier = Double(value)
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

    /// Function to start, play, or activate the node, all do the same thing
    public override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        self.internalAU!.startNote(Int32(noteNumber), velocity: Int32(velocity))
    }

    /// Function to stop or bypass the node, both are equivalent
    public override func stop(noteNumber: MIDINoteNumber) {
        self.internalAU!.stopNote(Int32(noteNumber))
    }
}
