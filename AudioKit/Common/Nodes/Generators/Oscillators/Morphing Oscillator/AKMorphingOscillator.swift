//
//  AKMorphingOscillator.swift
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
///   - waveformArray:      An array of exactly four waveforms
///   - frequency:          Frequency (in Hz)
///   - amplitude:          Amplitude (typically a value between 0 and 1).
///   - index:              Index of the wavetable to use (fractional are okay).
///   - detuningOffset:     Frequency offset in Hz.
///   - detuningMultiplier: Frequency detuning multiplier
///   - phase:              Initial phase of waveform, expects a value 0-1
///
public class AKMorphingOscillator: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKMorphingOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveformArray = [AKTable]()
    private var phase: Double

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var indexParameter: AUParameter?
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

    /// In cycles per second, or Hz.
    public var frequency: Double = 440 {
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
    public var amplitude: Double = 1 {
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


    /// Index of the wavetable to use (fractional are okay).
    public var index: Double = 0.0 {
        willSet {
            let transformedValue = Float(newValue) / Float(waveformArray.count - 1)
//            if internalAU!.isSetUp() {
//                indexParameter?.setValue(Float(transformedValue), originator: token!)
//            } else {
                internalAU?.index = Float(transformedValue)
//            }
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveformArray: [AKTable(.Triangle), AKTable(.Square), AKTable(.Sine), AKTable(.Sawtooth)])
    }
    
    /// Initialize this Morpher node
    ///
    /// - Parameters:
    ///   - waveformArray:      An array of exactly four waveforms
    ///   - frequency:          Frequency (in Hz)
    ///   - amplitude:          Amplitude (typically a value between 0 and 1).
    ///   - index:              Index of the wavetable to use (fractional are okay).
    ///   - detuningOffset:     Frequency offset in Hz.
    ///   - detuningMultiplier: Frequency detuning multiplier
    ///   - phase:              Initial phase of waveform, expects a value 0-1
    ///
    public init(
        waveformArray: [AKTable],
        frequency: Double = 440,
        amplitude: Double = 0.5,
        index: Double = 0.0,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1,
        phase: Double = 0) {

        self.waveformArray = waveformArray
        self.frequency = frequency
        self.amplitude = amplitude
        self.phase = phase
        self.index = index
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x6d6f7266 /*'morf'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKMorphingOscillatorAudioUnit.self,
            as: description,
            name: "Local AKMorphingOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKMorphingOscillatorAudioUnit

            AudioKit.engine.attach(self.avAudioNode)

            for i in 0 ..< waveformArray.count {
                self.internalAU?.setupWaveform(UInt32(i), size: Int32(waveformArray[i].size))
                for j in 0 ..< waveformArray[i].size{
                    self.internalAU?.setWaveform(UInt32(i), withValue: waveformArray[i].values[j], at: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter          = tree.value(forKey: "frequency")          as? AUParameter
        amplitudeParameter          = tree.value(forKey: "amplitude")          as? AUParameter
        indexParameter              = tree.value(forKey: "index")              as? AUParameter
        detuningOffsetParameter     = tree.value(forKey: "detuningOffset")     as? AUParameter
        detuningMultiplierParameter = tree.value(forKey: "detuningMultiplier") as? AUParameter
        
        token = tree.token(byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                switch address {
                case self.frequencyParameter!.address:
                    self.frequency = Double(value)
                case self.amplitudeParameter!.address:
                    self.amplitude = Double(value)
                case self.indexParameter!.address:
                    self.index = Double(value)
                case self.detuningOffsetParameter!.address:
                    self.detuningOffset = Double(value)
                case self.detuningMultiplierParameter!.address:
                    self.detuningMultiplier = Double(value)
                default:
                  break
                }
            }
        })
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.index = Float(index) / Float(waveformArray.count - 1)
        internalAU?.detuningOffset = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
