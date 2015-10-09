//
//  AKAUReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public class AKAUReverb: AKOperation {
    let reverbAU = AVAudioUnitReverb()
    public var wetDryMix:Float = 50.0 {
        didSet {
            reverbAU.wetDryMix = wetDryMix
        }
    }
    
    public init(_ input: AKOperation) {
        super.init()
        output = reverbAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
    
    public func loadFactoryPreset(preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }
    
}