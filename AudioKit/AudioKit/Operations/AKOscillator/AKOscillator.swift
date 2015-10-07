//
//  AKOscillator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKOscillator: AKOperation {

    var internalAU: AKOscillatorAudioUnit?

    var frequencyParameter: AUParameter?
    var amplitudeParameter:       AUParameter?

    var token: AUParameterObserverToken?

    public var frequency: Float = 1000.0 {
        didSet {
            frequencyParameter?.setValue(frequency, originator: token!)
        }
    }

    public var amplitude: Float = 50 {
        didSet {
            amplitudeParameter?.setValue(amplitude, originator: token!)
        }
    }

    public init(_ input: AKOperation) {
        super.init()

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

        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKOscillatorAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }

        guard let tree = internalAU?.parameterTree else { return }

        frequencyParameter = tree.valueForKey("frequency")    as? AUParameter
        amplitudeParameter       = tree.valueForKey("amplitude") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.frequencyParameter!.address {
                    self.frequency = value
                }
                else if address == self.amplitudeParameter!.address {
                    self.amplitude = value
                }
            }
        }

    }
}
