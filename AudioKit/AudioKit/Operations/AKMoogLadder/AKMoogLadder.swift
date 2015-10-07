//
//  AKMoogLadder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMoogLadder: AKOperation {
    
    var internalAU: AKMoogLadderAudioUnit?
    
    var cutoffFrequencyParameter: AUParameter?
    var resonanceParameter:       AUParameter?
    
    var token: AUParameterObserverToken?
    
    public var cutoffFrequency: Float = 1000.0 {
        didSet {
            cutoffFrequencyParameter?.setValue(cutoffFrequency, originator: token!)
        }
    }
    
    public var resonance: Float = 50 {
        didSet {
            resonanceParameter?.setValue(resonance, originator: token!)
        }
    }
    
    public init(_ input: AKOperation) {
        super.init()
        
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x6d676c64 /*'mgld'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0
        
        AUAudioUnit.registerSubclass(
            AKMoogLadderAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKMoogLadder",
            version: UInt32.max)
        
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in
            
            guard let avAudioUnitEffect = avAudioUnit else { return }
            
            self.output = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKMoogLadderAudioUnit
            AKManager.sharedInstance.engine.attachNode(self.output!)
            AKManager.sharedInstance.engine.connect(input.output!, to: self.output!, format: nil)
        }
        
        guard let tree = internalAU?.parameterTree else { return }
        
        cutoffFrequencyParameter = tree.valueForKey("cutoff")    as? AUParameter
        resonanceParameter       = tree.valueForKey("resonance") as? AUParameter
        
        token = tree.tokenByAddingParameterObserver {
            address, value in
            
            dispatch_async(dispatch_get_main_queue()) {
                if address == self.cutoffFrequencyParameter!.address {
                    self.cutoffFrequency = value
                }
                else if address == self.resonanceParameter!.address {
                    self.resonance = value
                }
            }
        }
        
    }
}
