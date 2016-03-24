//
//  AKPluckedString.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Karplus-Strong plucked string instrument.
///
/// - parameter frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
/// - parameter amplitude: Amplitude
/// - parameter lowestFrequency: This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.
///
public class AKPluckedString: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKPluckedStringAudioUnit?
    internal var token: AUParameterObserverToken?

    private var frequencyParameter: AUParameter?
    private var amplitudeParameter: AUParameter?
    private var lowestFrequency: Double

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    public var frequency: Double = 110 {
        didSet {
            internalAU?.frequency = Float(frequency)
        }
    }

    /// Ramp to frequency over 20 ms
    ///
    /// - parameter frequency: Target Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    ///
    public func ramp(frequency frequency: Double) {
        frequencyParameter?.setValue(Float(frequency), originator: token!)
    }

    /// Amplitude
    public var amplitude: Double = 0.5 {
        didSet {
            internalAU?.amplitude = Float(amplitude)
        }
    }

    /// Ramp to amplitude over 20 ms
    ///
    /// - parameter amplitude: Target Amplitude
    ///
    public func ramp(amplitude amplitude: Double) {
        amplitudeParameter?.setValue(Float(amplitude), originator: token!)
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize the pluck with defaults
    convenience override init() {
        self.init(frequency: 110)
    }
    
    /// Initialize this pluck node
    ///
    /// - parameter frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    /// - parameter amplitude: Amplitude
    /// - parameter lowestFrequency: This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.
    ///
    public init(
        frequency: Double,
        amplitude: Double = 0.5,
        lowestFrequency: Double = 110) {

        self.frequency = frequency
        self.amplitude = amplitude
        self.lowestFrequency = lowestFrequency
            
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x706c756b /*'pluk'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPluckedStringAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKPluckedString",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKPluckedStringAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree.valueForKey("frequency") as? AUParameter
        amplitudeParameter = tree.valueForKey("amplitude") as? AUParameter

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
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    public override func duplicate() -> AKVoice {
        let copy = AKPluckedString(frequency: self.frequency, amplitude: self.amplitude, lowestFrequency: self.lowestFrequency)
        return copy
    }
    
    /// Trigger the sound with an optional set of parameters
    /// - parameter frequency: Frequency in Hz
    /// - amplitude amplitude: Volume
    ///
    public func trigger(frequency frequency: Double, amplitude: Double = 1) {
        self.frequency = frequency
        self.amplitude = amplitude
        self.internalAU!.start()
        self.internalAU!.triggerFrequency(Float(frequency), amplitude: Float(amplitude))
    }

    /// Function to start, play, or activate the node, all do the same thing
    public override func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
  override   public func stop() {
        self.internalAU!.stop()
    }
}
