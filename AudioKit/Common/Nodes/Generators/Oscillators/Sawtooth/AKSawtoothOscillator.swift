//
//  AKSawtoothOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Bandlimited sawtooth oscillator This is a bandlimited sawtooth oscillator
/// ported from the "sawtooth" function from the Faust programming language.
///
/// - parameter frequency: In cycles per second, or Hz.
/// - parameter amplitude: Output Amplitude.
/// - parameter detuningOffset: Frequency offset in Hz.
/// - parameter detuningMultiplier: Frequency detuning multiplier
///
public class AKSawtoothOscillator: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKSawtoothOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
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
                frequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    
    /// Output Amplitude.
    public var amplitude: Double = 1 {
        willSet {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    
    /// Frequency offset in Hz.
    public var detuningOffset: Double = 0 {
        willSet {
            if detuningOffset != newValue {
                detuningOffsetParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    
    /// Frequency detuning multiplier
    public var detuningMultiplier: Double = 1 {
        willSet {
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
        self.init(frequency: 440)
    }

    /// Initialize this sawtooth node
    ///
    /// - parameter frequency: In cycles per second, or Hz.
    /// - parameter amplitude: Output Amplitude.
    /// - parameter detuningOffset: Frequency offset in Hz.
    /// - parameter detuningMultiplier: Frequency detuning multiplier
    ///
    public init(
        frequency: Double,
        amplitude: Double = 0.5,
        detuningOffset: Double = 0,
        detuningMultiplier: Double = 1) {


        self.frequency = frequency
        self.amplitude = amplitude
        self.detuningOffset = detuningOffset
        self.detuningMultiplier = detuningMultiplier

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x7361776f /*'sawo'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKSawtoothOscillatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKSawtoothOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKSawtoothOscillatorAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter          = tree.valueForKey("frequency")          as? AUParameter
        amplitudeParameter          = tree.valueForKey("amplitude")          as? AUParameter
        detuningOffsetParameter     = tree.valueForKey("detuningOffset")     as? AUParameter
        detuningMultiplierParameter = tree.valueForKey("detuningMultiplier") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
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
        }
        frequencyParameter?.setValue(Float(frequency), originator: token!)
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
        detuningOffsetParameter?.setValue(Float(detuningOffset), originator: token!)
        detuningMultiplierParameter?.setValue(Float(detuningMultiplier), originator: token!)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func duplicate() -> AKVoice {
        let copy = AKSawtoothOscillator(frequency: self.frequency, amplitude: self.amplitude, detuningOffset: self.detuningOffset, detuningMultiplier: self.detuningMultiplier)
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
