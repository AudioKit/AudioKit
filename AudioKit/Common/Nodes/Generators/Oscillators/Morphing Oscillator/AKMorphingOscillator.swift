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
/// - parameter frequency: Frequency (in Hz)
/// - parameter amplitude: Amplitude (typically a value between 0 and 1).
/// - parameter index: Index of the wavetable to use (fractional are okay).
/// - parameter phase: Initial phase of waveform, expects a value 0-1
///
public class AKMorphingOscillator: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKMorphingOscillatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var waveformArray: [AKTable] = []
    private var phase: Double

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?

    /// Frequency (in Hz)
    public var frequency: Double = 440 {
        didSet {
            internalAU?.frequency = Float(frequency)
        }
    }

    /// Ramp to frequency over 20 ms
    ///
    /// - parameter frequency: Target Frequency (in Hz)
    ///
    public func ramp(frequency frequency: Double) {
        frequencyParameter?.setValue(Float(frequency), originator: token!)
    }

    /// Amplitude (typically a value between 0 and 1).
    public var amplitude: Double = 0.5 {
        didSet {
            internalAU?.amplitude = Float(amplitude)
        }
    }

    /// Ramp to amplitude over 20 ms
    ///
    /// - parameter amplitude: Target Amplitude (typically a value between 0 and 1).
    ///
    public func ramp(amplitude amplitude: Double) {
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Index of the wavetable to use (fractional are okay).
    public var index: Double = 0.0 {
        didSet {
            internalAU?.index = Float(index) / Float(waveformArray.count - 1)
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this Morpher node
    ///
    /// - parameter frequency: Frequency (in Hz)
    /// - parameter amplitude: Amplitude (typically a value between 0 and 1).
    /// - parameter index: Index of the wavetable to use (fractional are okay).
    /// - parameter phase: Initial phase of waveform, expects a value 0-1
    ///
    public init(
        waveformArray: [AKTable] = [AKTable(.Sawtooth), AKTable(.Square), AKTable(.Sine), AKTable(.Triangle)],
        frequency: Double = 440,
        amplitude: Double = 0.5,
        index: Double = 0.0,
        phase: Double = 0) {


        self.waveformArray = waveformArray
        self.frequency = frequency
        self.amplitude = amplitude
        self.phase = phase
        self.index = index

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

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            
            /// AOP need to set up phase
            for i in 0..<waveformArray.count {
                self.internalAU?.setupWaveform(UInt32(i), size: Int32(waveformArray[i].size))
                for var j = 0; j < waveformArray[i].size; j++ {
                    self.internalAU?.setWaveform(UInt32(i), withValue: waveformArray[i].values[j], atIndex: UInt32(j))
                }
            }
            self.internalAU?.finalize()
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter     = tree.valueForKey("frequency")     as? AUParameter
        amplitudeParameter     = tree.valueForKey("amplitude")     as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter!.address {
                    self.frequency = Double(value)
                } else if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        }
        internalAU?.frequency = Float(frequency)
        internalAU?.amplitude = Float(amplitude)
        internalAU?.index = Float(index) / Float(waveformArray.count - 1)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func copy() -> AKVoice {
        let copy = AKMorphingOscillator(waveformArray: self.waveformArray, frequency: self.frequency, amplitude: self.amplitude, index: self.index, phase: self.phase)
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
