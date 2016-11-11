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
open class AKWhiteNoise: AKNode, AKPlayable {

    // MARK: - Properties

    internal var internalAU: AKWhiteNoiseAudioUnit?
    internal var token: AUParameterObserverToken?


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

    /// Amplitude. (Value between 0-1).
    open var amplitude: Double = 1 {
        willSet {
            if amplitude != newValue {
                amplitudeParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
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
        description.componentSubType      = fourCC("wnoz")
        description.componentManufacturer = fourCC("AuKt")
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

        token = tree.token (byAddingParameterObserver: {
            address, value in

            DispatchQueue.main.async {
                if address == self.amplitudeParameter!.address {
                    self.amplitude = Double(value)
                }
            }
        })
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
