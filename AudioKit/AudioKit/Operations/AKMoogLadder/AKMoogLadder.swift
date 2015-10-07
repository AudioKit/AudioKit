//
//  AKMoogLadder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMoogLadder: AKOperation {
    
    var moogLadderAU: AKMoogLadderAudioUnit?
    
    var cutoffParameter: AUParameter?
    var resonanceParameter: AUParameter?
    var parameterObserverToken: AUParameterObserverToken?
    
    public var cutoffFrequency: Float = 1000.0 {
        didSet {    
            cutoffParameter?.setValue(cutoffFrequency, originator: parameterObserverToken!)
        }
    }
    
    public var resonance: Float = 50 {
        didSet {
            resonanceParameter?.setValue(resonance, originator: parameterObserverToken!)
        }
    }

    public init(_ input: AKOperation) {
        super.init()

        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x6d676c64 /*'mgld'*/
        componentDescription.componentManufacturer = 0x41754b74 /*'AuKt'*/
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0

        AUAudioUnit.registerSubclass(
            AKMoogLadderAudioUnit.self,
            asComponentDescription: componentDescription,
            name: "Local AKMoogLadder",
            version: UInt32.max)

        AVAudioUnit.instantiateWithComponentDescription(componentDescription, options: []) { avAudioUnit, error in
            guard let avAudioUnitEffect = avAudioUnit else { return }
            
            self.output = avAudioUnitEffect
            self.moogLadderAU = avAudioUnitEffect.AUAudioUnit as? AKMoogLadderAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }
        
        guard let paramTree = moogLadderAU?.parameterTree else { return }
        
        cutoffParameter = paramTree.valueForKey("cutoff") as? AUParameter
        resonanceParameter = paramTree.valueForKey("resonance") as? AUParameter
        
        parameterObserverToken = paramTree.tokenByAddingParameterObserver { address, value in
            dispatch_async(dispatch_get_main_queue()) {
                if address == self.cutoffParameter!.address {
                    self.cutoffFrequency = value
                }
                else if address == self.resonanceParameter!.address {
                    self.resonance = value
                }
            }
        }

    }
}
