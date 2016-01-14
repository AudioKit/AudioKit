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
/// - parameter detuning: Frequency offset in Hz, Default: 0
///
public class AKOscillator: AKVoice {

    // MARK: - Properties


    internal var internalAU: AKOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveform: AKTable?

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var detuningParameter:  AUParameter?

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
    
    /// Detuning frequency in Hz, Default: 0
    public var detuning: Double = 0 {
        willSet(newValue) {
            if detuning != newValue {
                detuningParameter?.setValue(Float(newValue), originator: token!)
            }
        }
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

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this oscillator node
    ///
    /// - parameter frequency: Frequency in cycles per second
    /// - parameter amplitude: Output Amplitude.
    /// - parameter detuning: Frequency offset in Hz, Default: 0
    ///
    public init(
        waveform: AKTable = AKTable(.Sine),
        frequency: Double = 440,
        amplitude: Double = 1,
        detuning: Double = 0) {


        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
        self.detuning = detuning

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

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            self.internalAU?.setupWaveform(Int32(waveform.size))
            for var i = 0; i < waveform.size; i++ {
                self.internalAU?.setWaveformValue(waveform.values[i], atIndex: UInt32(i))
            }
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree.valueForKey("frequency") as? AUParameter
        amplitudeParameter = tree.valueForKey("amplitude") as? AUParameter
        detuningParameter  = tree.valueForKey("detuning")  as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                } else if address == self.detuningParameter!.address {
                    self.detuning = Double(value)
                }
            }
        }
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.detuning  = Float(detuning)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func copy() -> AKVoice {
        let copy = AKOscillator(waveform: self.waveform!, frequency: self.frequency, amplitude: self.amplitude, detuning:  self.detuning)
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
