//
//  AKMoogLadder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMoogLadder : AVAudioUnit {
    
    public var effect: AVAudioUnit?
    public var componentDescription = AudioComponentDescription()
    
    public override init() {
        componentDescription.componentType = kAudioUnitType_Effect
    }
    
    public func setup() {
        
        AVAudioUnit.instantiateWithComponentDescription(componentDescription, options: []) { avAudioUnit, error in
            guard let avAudioUnitEffect = avAudioUnit else { return }
            
            self.effect = avAudioUnitEffect
//            self.engine.attachNode(avAudioUnitEffect)
        }
    }
}