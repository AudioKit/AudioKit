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
/// - parameter frequency: Frequency in cycles per second
/// - parameter amplitude: Output Amplitude.
/// - parameter detuningOffset: Frequency offset in Hz.
/// - parameter detuningMultiplier: Frequency detuning multiplier
///
public class AKOscillator: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveform: AKTable?

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var detuningOffsetParameter: AUParameter?
    private var detuningMultiplierParameter: AUParameter?

    /// Frequency in cycles per second
    public var frequency: Double = 440 {
        didSet {
            internalAU?.frequency = Float(frequency)
        }
    }

    /// Ramp to frequency over 20 ms
    ///
    /// - parameter frequency: Target Frequency in cycles per second
    ///
    public func ramp(frequency frequency: Double) {
        frequencyParameter?.setValue(Float(frequency), originator: token!)
    }

    /// Output Amplitude.
    public var amplitude: Double = 1 {
        didSet {
            internalAU?.amplitude = Float(amplitude)
        }
    }

    /// Ramp to amplitude over 20 ms
    ///
    /// - parameter amplitude: Target Output Amplitude.
    ///
    public func ramp(amplitude amplitude: Double) {
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Frequency offset in Hz.
    public var detuningOffset: Double = 0 {
        didSet {
            internalAU?.detuningOffset = Float(detuningOffset)
        }
    }

    /// Ramp to detuningOffset over 20 ms
    ///
    /// - parameter detuningOffset: Target Frequency offset in Hz.
    ///
    public func ramp(detuningOffset detuningOffset: Double) {
        detuningOffsetParameter?.setValue(Float(detuningOffset), originator: token!)
    }

    /// Frequency detuning multiplier
    public var detuningMultiplier: Double = 1 {
        didSet {
            internalAU?.detuningMultiplier = Float(detuningMultiplier)
        }
    }

    /// Ramp to detuningMultiplier over 20 ms
    ///
    /// - parameter detuningMultiplier: Target Frequency detuning multiplier
    ///
    public func ramp(detuningMultiplier detuningMultiplier: Double) {
        detuningMultiplierParameter?.setValue(Float(detuningMultiplier), originator: token!)
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
    /// - parameter frequency: Frequency in cycles per second
    /// - parameter amplitude: Output Amplitude.
    /// - parameter detuningOffset: Frequency offset in Hz.
    /// - parameter detuningMultiplier: Frequency detuning multiplier
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
        description.componentSubType      = 0x6f73636c /*'oscl'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKOscillatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKOscillator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKOscillatorAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for var i = 0; i < waveform.size; i++ {
                self.internalAU?.setWaveformValue(waveform.values[i], atIndex: UInt32(i))
            }
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
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.detuningOffset = Float(detuningOffset)
        internalAU?.detuningMultiplier = Float(detuningMultiplier)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func duplicate() -> AKVoice {
        let copy = AKOscillator(waveform: self.waveform!, frequency: self.frequency, amplitude: self.amplitude, detuningOffset: self.detuningOffset, detuningMultiplier: self.detuningMultiplier)
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
