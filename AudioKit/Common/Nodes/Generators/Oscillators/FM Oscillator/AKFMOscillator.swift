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
/// - Parameters:
///   - waveform: Shape of the oscillation
///   - baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
///   - amplitude: Output Amplitude.
///
open class AKFMOscillator: AKNode, AKToggleable {

    // MARK: - Properties

    internal var internalAU: AKFMOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    fileprivate var waveform: AKTable?

    fileprivate var baseFrequencyParameter: AUParameter?
    fileprivate var carrierMultiplierParameter: AUParameter?
    fileprivate var modulatingMultiplierParameter: AUParameter?
    fileprivate var modulationIndexParameter: AUParameter?
    fileprivate var amplitudeParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            if rampTime != newValue {
                internalAU?.rampTime = newValue
                internalAU?.setUpParameterRamp()
            }
        }
    }

    /// In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    open var baseFrequency: Double = 440 {
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
    open var carrierMultiplier: Double = 1.0 {
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
    open var modulatingMultiplier: Double = 1 {
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
    open var modulationIndex: Double = 1 {
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
    ///   - waveform: Shape of the oscillation
    ///   - baseFrequency: In cycles per second, or Hz, this is the common denominator for the carrier and modulating frequencies.
    ///   - carrierMultiplier: This multiplied by the baseFrequency gives the carrier frequency.
    ///   - modulatingMultiplier: This multiplied by the baseFrequency gives the modulating frequency.
    ///   - modulationIndex: This multiplied by the modulating frequency gives the modulation amplitude.
    ///   - amplitude: Output Amplitude.
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
        description.componentSubType      = fourCC("fosc")
        description.componentManufacturer = fourCC("AuKt")
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKFMOscillatorAudioUnit.self,
            as: description,
            name: "Local AKFMOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKFMOscillatorAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for i in 0 ..< waveform.size {
                self.internalAU?.setWaveformValue(waveform.values[i], at: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        baseFrequencyParameter        = tree.value(forKey: "baseFrequency")        as? AUParameter
        carrierMultiplierParameter    = tree.value(forKey: "carrierMultiplier")    as? AUParameter
        modulatingMultiplierParameter = tree.value(forKey: "modulatingMultiplier") as? AUParameter
        modulationIndexParameter      = tree.value(forKey: "modulationIndex")      as? AUParameter
        amplitudeParameter            = tree.value(forKey: "amplitude")            as? AUParameter

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
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
        })
        internalAU?.baseFrequency = Float(baseFrequency)
        internalAU?.carrierMultiplier = Float(carrierMultiplier)
        internalAU?.modulatingMultiplier = Float(modulatingMultiplier)
        internalAU?.modulationIndex = Float(modulationIndex)
        internalAU?.amplitude = Float(amplitude)
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
