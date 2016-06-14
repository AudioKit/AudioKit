//
//  AKWhiteNoise.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// White noise generator
///
/// - parameter amplitude: Amplitude. (Value between 0-1).
///
public class AKWhiteNoise: AKVoice {

    // MARK: - Properties

    internal var internalAU: AKWhiteNoiseAudioUnit?
    internal var token: AUParameterObserverToken?


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

    /// Amplitude. (Value between 0-1).
    public var amplitude: Double = 1 {
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

    /// Initialize this noise node
    ///
    /// - parameter amplitude: Amplitude. (Value between 0-1).
    ///
    public init(
        amplitude: Double = 1) {


        self.amplitude = amplitude

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Generator
        description.componentSubType      = 0x776e6f7a /*'wnoz'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKWhiteNoiseAudioUnit.self,
            as: description,
            name: "Local AKWhiteNoise",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiate(with: description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitGenerator = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitGenerator
            self.internalAU = avAudioUnitGenerator.auAudioUnit as? AKWhiteNoiseAudioUnit

            AudioKit.engine.attach(self.avAudioNode)
        }

        guard let tree = internalAU?.parameterTree else { return }

        amplitudeParameter = tree.value(forKey: "amplitude") as? AUParameter
        
        let observer: AUParameterObserver = {
            address, value in
            
            let executionBlock = {
                if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
            
            DispatchQueue.main.async(execute: executionBlock)
        }
        
        token = tree.token(byAddingParameterObserver: observer)
        internalAU?.amplitude = Float(amplitude)
    }

    /// Function create an identical new node for use in creating polyphonic instruments
    override public func duplicate() -> AKVoice {
        let copy = AKWhiteNoise(amplitude: self.amplitude)
        return copy
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
