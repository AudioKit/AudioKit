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
/// - parameter waveformArray:      An array of exactly four waveforms
/// - parameter frequency:          Frequency (in Hz)
/// - parameter amplitude:          Amplitude (typically a value between 0 and 1).
/// - parameter index:              Index of the wavetable to use (fractional are okay).
/// - parameter detuningOffset:     Frequency offset in Hz.
/// - parameter detuningMultiplier: Frequency detuning multiplier
/// - parameter phase:              Initial phase of waveform, expects a value 0-1
///
public class AKMorphingOscillator: AKVoice {

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
        willSet(newValue) {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }
    
    /// In cycles per second, or Hz.
    public var frequency: Double = 440 {
        willSet(newValue) {
            if frequency != newValue {
                frequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    
    /// Output Amplitude.
    public var amplitude: Double = 1 {
        willSet(newValue) {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Index of the wavetable to use (fractional are okay).
    public var index: Double = 0.0 {
        willSet(newValue) {
            internalAU?.index = Float(newValue) / Float(waveformArray.count - 1)
        }
    }

    /// Frequency offset in Hz.
    public var detuningOffset: Double = 0 {
        willSet(newValue) {
            if detuningOffset != newValue {
                detuningOffsetParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    
    /// Frequency detuning multiplier
    public var detuningMultiplier: Double = 1 {
        willSet(newValue) {
            if detuningMultiplier != newValue {
                detuningMultiplierParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization
    
    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveformArray: [AKTable(.Triangle), AKTable(.Square), AKTable(.Sine), AKTable(.Sawtooth)])
    }
    
    /// Initialize this Morpher node
    ///
    /// - parameter waveformArray:      An array of exactly four waveforms
    /// - parameter frequency:          Frequency (in Hz)
    /// - parameter amplitude:          Amplitude (typically a value between 0 and 1).
    /// - parameter index:              Index of the wavetable to use (fractional are okay).
    /// - parameter detuningOffset:     Frequency offset in Hz.
    /// - parameter detuningMultiplier: Frequency detuning multiplier
    /// - parameter phase:              Initial phase of waveform, expects a value 0-1
    ///
    public init(
        waveformArray: [AKTable],
        frequency: Double = 440,
        amplitude: Double = 0.5,
        index: Double = 0.0,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1,
        phase: Double = 0) {

        // AOP Note: Waveforms are currently hardcoded, need to upgrade this
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
            asComponentDescription: description,
            name: "Local AKMorphingOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKMorphingOscillatorAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            
            /// AOP need to set up phase
            for i in 0 ..< waveformArray.count {
                self.internalAU?.setupWaveform(UInt32(i), size: Int32(waveformArray[i].size))
                for j in 0 ..< waveformArray[i].size{
                    self.internalAU?.setWaveform(UInt32(i), withValue: waveformArray[i].values[j], atIndex: UInt32(j))
                }
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter          = tree.valueForKey("frequency")          as? AUParameter
        amplitudeParameter          = tree.valueForKey("amplitude")          as? AUParameter
        indexParameter              = tree.valueForKey("index")              as? AUParameter
        detuningOffsetParameter     = tree.valueForKey("detuningOffset")     as? AUParameter
        detuningMultiplierParameter = tree.valueForKey("detuningMultiplier") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                } else if address == self.indexParameter!.address {
                    self.index = Double(value)
                } else if address == self.detuningOffsetParameter!.address {
                    self.detuningOffset = Double(value)
                } else if address == self.detuningMultiplierParameter!.address {
                    self.detuningMultiplier = Double(value)
                }
            }
        }
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.index = Float(index) / Float(waveformArray.count - 1)
        internalAU?.detuningOffset = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func duplicate() -> AKVoice {
        let copy = AKMorphingOscillator(waveformArray: self.waveformArray, frequency: self.frequency, amplitude: self.amplitude, index: self.index, detuningOffset: self.detuningOffset, detuningMultiplier: self.detuningMultiplier, phase: self.phase)
        return copy
    }

    /// Function to start, play, or activate the node, all do the same thing
    public override func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public override func stop() {
        self.internalAU!.stop()
    }
}
