//
//  AKMorphingOscillatorBank.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// This is an oscillator with linear interpolation that is capable of morphing
/// between an arbitrary number of wavetables.
///
/// - Parameters:
///   - waveform:           The waveform of oscillation
///   - index:              Index of the wavetable to use (fractional are okay).
///   - attackDuration:     Attack time
///   - decayDuration:      Decay time
///   - sustainLevel:       Sustain Level
///   - releaseDuration:    Release time
///   - detuningOffset:     Frequency offset in Hz.
///   - detuningMultiplier: Frequency detuning multiplier
///
open class AKMorphingOscillatorBank: AKPolyphonicNode, AKComponent {
    public typealias AKAudioUnitType = AKMorphingOscillatorBankAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "morb")

    // MARK: - Properties

    internal var internalAU: AKAudioUnitType?
    internal var token: AUParameterObserverToken?

    fileprivate var waveformArray = [AKTable]()

    fileprivate var attackDurationParameter:     AUParameter?
    fileprivate var decayDurationParameter:      AUParameter?
    fileprivate var sustainLevelParameter:       AUParameter?
    fileprivate var releaseDurationParameter:    AUParameter?
    fileprivate var detuningOffsetParameter:     AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    open var index: Double = 0.0 {
        willSet {
            let transformedValue = Float(newValue) / Float(waveformArray.count - 1)
            internalAU?.index = Float(transformedValue)
        }
    }

    /// Attack time
    open var attackDuration: Double = 0.1 {
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
    open var decayDuration: Double = 0.1 {
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
    open var sustainLevel: Double = 1.0 {
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
    open var releaseDuration: Double = 0.1 {
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
    open var detuningOffset: Double = 0 {
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
    open var detuningMultiplier: Double = 1 {
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
        self.init(waveformArray: [AKTable(.triangle), AKTable(.square), AKTable(.sine), AKTable(.sawtooth)])
    }

    /// Initialize this oscillator node
    ///
    /// - Parameters:
    ///   - waveform:           The waveform of oscillation
    ///   - index:              Index of the wavetable to use (fractional are okay).
    ///   - attackDuration:     Attack time
    ///   - decayDuration:      Decay time
    ///   - sustainLevel:       Sustain Level
    ///   - releaseDuration:    Release time
    ///   - detuningOffset:     Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveformArray: [AKTable],
        index: Double = 0,
        attackDuration: Double = 0.1,
        decayDuration: Double = 0.1,
        sustainLevel: Double = 1.0,
        releaseDuration: Double = 0.1,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1) {

        self.waveformArray = waveformArray
        self.index = index

        self.attackDuration = attackDuration
        self.decayDuration = decayDuration
        self.sustainLevel = sustainLevel
        self.releaseDuration = releaseDuration
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        _Self.register()

        super.init()
        AVAudioUnit.instantiate(with: _Self.ComponentDescription, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKAudioUnitType

            AudioKit.engine.attach(self.avAudioNode)
            for (i, waveform) in waveformArray.enumerated() {
                self.internalAU?.setupWaveform(UInt32(i), size: Int32(UInt32(waveform.count)))
                for (j, sample) in waveform.enumerated() {
                    self.internalAU?.setWaveform(UInt32(i), withValue: sample, at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        attackDurationParameter     = tree["attackDuration"]
        decayDurationParameter      = tree["decayDuration"]
        sustainLevelParameter       = tree["sustainLevel"]
        releaseDurationParameter    = tree["releaseDuration"]
        detuningOffsetParameter     = tree["detuningOffset"]
        detuningMultiplierParameter = tree["detuningMultiplier"]

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.attackDurationParameter!.address {
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
        internalAU?.index = Float(index) / Float(waveformArray.count - 1)

        internalAU?.attackDuration     = Float(attackDuration)
        internalAU?.decayDuration      = Float(decayDuration)
        internalAU?.sustainLevel       = Float(sustainLevel)
        internalAU?.releaseDuration    = Float(releaseDuration)
        internalAU?.detuningOffset     = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    // MARK: - AKPolyphonic

    /// Function to start, play, or activate the node, all do the same thing
    open override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        self.internalAU!.startNote(Int32(noteNumber), velocity: Int32(velocity))
    }

    /// Function to stop or bypass the node, both are equivalent
    open override func stop(noteNumber: MIDINoteNumber) {
        self.internalAU!.stopNote(Int32(noteNumber))
    }
}
