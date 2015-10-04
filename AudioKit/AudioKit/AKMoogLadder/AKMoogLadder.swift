//
//  AKMoogLadder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

public class AKMoogLadder {
    
    public var output: AVAudioUnit?
    var componentDescription = AudioComponentDescription()
    
    public init() {

        componentDescription.componentType = kAudioUnitType_Effect
        AUAudioUnit.registerSubclass(
            AKMoogLadderAudioUnit.self,
            asComponentDescription: componentDescription,
            name: "Local AKMoogLadder",
            version: UInt32.max)
    }
    
    public func setup() {
        AVAudioUnit.instantiateWithComponentDescription(componentDescription, options: []) { avAudioUnit, error in
            guard let avAudioUnitEffect = avAudioUnit else { return }
            
            self.output = avAudioUnitEffect
        }
    }
}
