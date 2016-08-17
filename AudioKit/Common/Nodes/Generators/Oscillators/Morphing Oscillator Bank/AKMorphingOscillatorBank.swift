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
public class AKMorphingOscillatorBank: AKPolyphonicNode {

    // MARK: - Properties

    internal var internalAU: AKMorphingOscillatorBankAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveformArray = [AKTable]()

    private var attackDurationParameter:     AUParameter?
    private var decayDurationParameter:      AUParameter?
    private var sustainLevelParameter:       AUParameter?
    private var releaseDurationParameter:    AUParameter?
    private var detuningOffsetParameter:     AUParameter?
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

    /// Index of the wavetable to use (fractional are okay).
    public var index: Double = 0.0 {
        willSet {
            let transformedValue = Float(newValue) / Float(waveformArray.count - 1)
            internalAU?.index = Float(transformedValue)
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
        self.init(waveformArray: [AKTable(.Triangle), AKTable(.Square), AKTable(.Sine), AKTable(.Sawtooth)])
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

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x6d6f7262 /*'morb'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKMorphingOscillatorBankAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKMorphingOscillatorBank",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKMorphingOscillatorBankAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            for i in 0 ..< waveformArray.count {
                self.internalAU?.setupWaveform(UInt32(i), size: Int32(waveformArray[i].size))
                for j in 0 ..< waveformArray[i].size {
                    self.internalAU?.setWaveform(UInt32(i), withValue: waveformArray[i].values[j], atIndex: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        attackDurationParameter     = tree.valueForKey("attackDuration")     as? AUParameter
        decayDurationParameter      = tree.valueForKey("decayDuration")      as? AUParameter
        sustainLevelParameter       = tree.valueForKey("sustainLevel")       as? AUParameter
        releaseDurationParameter    = tree.valueForKey("releaseDuration")    as? AUParameter
        detuningOffsetParameter     = tree.valueForKey("detuningOffset")     as? AUParameter
        detuningMultiplierParameter = tree.valueForKey("detuningMultiplier") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
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
        }
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
    public override func play(noteNumber noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        self.internalAU!.startNote(Int32(noteNumber), velocity: Int32(velocity))
    }

    /// Function to stop or bypass the node, both are equivalent
    public override func stop(noteNumber noteNumber: MIDINoteNumber) {
        self.internalAU!.stopNote(Int32(noteNumber))
    }
}
