//
//  AKFMOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Classic FM Synthesis audio generation.
///
/// - parameter baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
/// - parameter carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
/// - parameter modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
/// - parameter modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
/// - parameter amplitude: Output Amplitude.
///
public class AKFMOscillator: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKFMOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveform: AKTable?

    private var baseFrequencyParameter: AUParameter?
    private var carrierMultiplierParameter: AUParameter?
    private var modulatingMultiplierParameter: AUParameter?
    private var modulationIndexParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    
    /// Ramp Time represents the speed at which parameters are allowed to change
    public var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    public var baseFrequency: Double = 440 {
        willSet {
            if baseFrequency != newValue {
                if internalAU!.isSetUp() {
                    baseFrequencyParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.baseFrequency = Float(newValue)
                }
            }
        }
    }

    /// This multiplied by the baseFrequency gives the carrier frequency.
    public var carrierMultiplier: Double = 1.0 {
        willSet {
            if carrierMultiplier != newValue {
                if internalAU!.isSetUp() {
                    carrierMultiplierParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.carrierMultiplier = Float(newValue)
                }
            }
        }
    }

    /// This multiplied by the baseFrequency gives the modulating frequency.
    public var modulatingMultiplier: Double = 1 {
        willSet {
            if modulatingMultiplier != newValue {
                if internalAU!.isSetUp() {
                    modulatingMultiplierParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.modulatingMultiplier = Float(newValue)
                }
            }
        }
    }

    /// This multiplied by the modulating frequency gives the modulation amplitude.
    public var modulationIndex: Double = 1 {
        willSet {
            if modulationIndex != newValue {
                if internalAU!.isSetUp() {
                    modulationIndexParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.modulationIndex = Float(newValue)
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization
    
    /// Initialize the oscillator with defaults
    public convenience override init() {
        self.init(waveform: AKTable(.Sine))
    }

    /// Initialize this oscillator node
    ///
    /// - parameter baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    /// - parameter carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    /// - parameter modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    /// - parameter modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    /// - parameter amplitude: Output Amplitude.
    ///
    public init(
        waveform: AKTable,
        baseFrequency: Double = 440,
        carrierMultiplier: Double = 1.0,
        modulatingMultiplier: Double = 1,
        modulationIndex: Double = 1,
        amplitude: Double = 1) {


        self.waveform = waveform
        self.baseFrequency = baseFrequency
        self.carrierMultiplier = carrierMultiplier
        self.modulatingMultiplier = modulatingMultiplier
        self.modulationIndex = modulationIndex
        self.amplitude = amplitude

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x666f7363 /*'fosc'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFMOscillatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKFMOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKFMOscillatorAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for i in 0 ..< waveform.size {
                self.internalAU?.setWaveformValue(waveform.values[i], atIndex: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        baseFrequencyParameter        = tree.valueForKey("baseFrequency")        as? AUParameter
        carrierMultiplierParameter    = tree.valueForKey("carrierMultiplier")    as? AUParameter
        modulatingMultiplierParameter = tree.valueForKey("modulatingMultiplier") as? AUParameter
        modulationIndexParameter      = tree.valueForKey("modulationIndex")      as? AUParameter
        amplitudeParameter            = tree.valueForKey("amplitude")            as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.baseFrequencyParameter!.address {
                    self.baseFrequency = Double(value)
                } else if address == self.carrierMultiplierParameter!.address {
                    self.carrierMultiplier = Double(value)
                } else if address == self.modulatingMultiplierParameter!.address {
                    self.modulatingMultiplier = Double(value)
                } else if address == self.modulationIndexParameter!.address {
                    self.modulationIndex = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        }
        internalAU?.baseFrequency = Float(baseFrequency)
        internalAU?.carrierMultiplier = Float(carrierMultiplier)
        internalAU?.modulatingMultiplier = Float(modulatingMultiplier)
        internalAU?.modulationIndex = Float(modulationIndex)
        internalAU?.amplitude = Float(amplitude)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    override public func duplicate() -> AKVoice {
        let copy = AKFMOscillator(waveform: self.waveform!, baseFrequency: self.baseFrequency, carrierMultiplier: self.carrierMultiplier, modulatingMultiplier: self.modulatingMultiplier, modulationIndex: self.modulationIndex, amplitude: self.amplitude)
        return copy
    }

    /// Function to start, play, or activate the node, all do the same thing
    override public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
  override   public func stop() {
        self.internalAU!.stop()
    }
}
