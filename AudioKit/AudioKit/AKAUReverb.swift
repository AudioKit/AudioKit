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
    
    public init(_ input: AKOperation) {
        super.init()
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.Cathedral)
        reverb.wetDryMix = 50
        output = reverb
        AKManager.sharedManager.engine.attachNode(output!)
        AKManager.sharedManager.engine.connect(input.output!, to: output!, format: nil)
    }
    
}