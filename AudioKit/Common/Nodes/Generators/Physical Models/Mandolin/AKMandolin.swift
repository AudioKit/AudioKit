//
//  AKMandolin.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// STK Mandoline
///
/// - parameter frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
/// - parameter amplitude: Amplitude
///
public class AKMandolin: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKMandolinAudioUnit?
    internal var token: AUParameterObserverToken?

    private var frequencyParameter: AUParameter?
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

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    public var frequency: Double = 110 {
        willSet {
            if frequency != newValue {
                frequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Amplitude
    public var amplitude: Double = 0.5 {
        willSet {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    override public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize the mandolin with defaults
    override convenience init() {
        self.init(frequency: 110)
    }
    
    /// Initialize the STK Mandolin model
    ///
    /// - parameter frequency: Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    /// - parameter amplitude: Amplitude
    ///
    public init(
        frequency: Double = 440,
        amplitude: Double = 0.5) {


        self.frequency = frequency
        self.amplitude = amplitude
        
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x706c756b /*'mand'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKMandolinAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKMandolin",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.AUAudioUnit as? AKMandolinAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter       = tree.valueForKey("frequency")       as? AUParameter
        amplitudeParameter       = tree.valueForKey("amplitude")       as? AUParameter

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
    override public func duplicate() -> AKVoice {
        let copy = AKMandolin(frequency: self.frequency, amplitude: self.amplitude)
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
    override public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    override public func stop() {
        self.internalAU!.stop()
    }
}
