//
//  AKOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Reads from the table sequentially and repeatedly at given frequency. Linear
/// interpolation is applied for table look up from internal phase values.
///
/// - Parameters:
///   - frequency: Frequency in cycles per second
///   - amplitude: Output Amplitude.
///   - detuningOffset: Frequency offset in Hz.
///   - detuningMultiplier: Frequency detuning multiplier
///
open class AKOscillator: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    fileprivate var waveform: AKTable?

    fileprivate var frequencyParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?
    fileprivate var detuningOffsetParameter: AUParameter?
    fileprivate var detuningMultiplierParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// In cycles per second, or Hz.
    open var frequency: Double = 440 {
        willSet {
            if frequency != newValue {
                if internalAU!.isSetUp() {
                    frequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.frequency = Float(newValue)
                }
            }
        }
    }

    /// Output Amplitude.
    open var amplitude: Double = 1 {
        willSet {
            if amplitude != newValue {
                if internalAU!.isSetUp() {
                    amplitudeParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.amplitude = Float(newValue)
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
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
    ///   - frequency: Frequency in cycles per second
    ///   - amplitude: Output Amplitude.
    ///   - detuningOffset: Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        waveform: AKTable,
        frequency: Double = 440,
        amplitude: Double = 1,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1) {


        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = fourCC("oscl")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOscillatorAudioUnit.self,
            as: description,
            name: "Local AKOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKOscillatorAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for i in 0 ..< waveform.size {
                self.internalAU?.setWaveformValue(waveform.values[i], at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter          = tree.value(forKey: "frequency")          as? AUParameter
        amplitudeParameter          = tree.value(forKey: "amplitude")          as? AUParameter
        detuningOffsetParameter     = tree.value(forKey: "detuningOffset")     as? AUParameter
        detuningMultiplierParameter = tree.value(forKey: "detuningMultiplier") as? AUParameter

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                } else if address == self.detuningOffsetParameter!.address {
                    self.detuningOffset = Double(value)
                } else if address == self.detuningMultiplierParameter!.address {
                    self.detuningMultiplier = Double(value)
                }
            }
        })
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.detuningOffset = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)

    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
}
