//
//  AKFlatFrequencyResponseReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKFlatFrequencyResponseReverb: AKOperation {

    var reverbAU: AKFlatFrequencyResponseReverbAudioUnit?

    var reverbDurationParameter: AUParameter?
    var parameterObserverToken: AUParameterObserverToken?

    public var reverbDuration: Float = 0.5 {
        didSet {
            reverbDurationParameter?.setValue(reverbDuration, originator: parameterObserverToken!)
        }
    }

    public init(_ input: AKOperation, loopDuration: Float) {
        super.init()
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x616c7073 /*'alps'*/
        componentDescription.componentManufacturer = 0x41754b74 /*'AuKt'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0

        AUAudioUnit.registerSubclass(
            AKFlatFrequencyResponseReverbAudioUnit.self,
            asComponentDescription: componentDescription,
            name: "Local AKFlatFrequencyResponseReverb",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(componentDescription, options: []) { avAudioUnit, error in
            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.output = avAudioUnitEffect
            self.reverbAU = avAudioUnitEffect.AUAudioUnit as? AKFlatFrequencyResponseReverbAudioUnit
            AKManager.sharedManager.engine.attachNode(self.output!)
            AKManager.sharedManager.engine.connect(input.output!, to: self.output!, format: nil)
        }

        guard let paramTree = reverbAU?.parameterTree else { return }

        reverbDurationParameter = paramTree.valueForKey("reverbDuration") as? AUParameter

        parameterObserverToken = paramTree.tokenByAddingParameterObserver {
            address, value in
            dispatch_async(dispatch_get_main_queue()) {
                self.reverbDuration = value
            }
        }

    }
}
