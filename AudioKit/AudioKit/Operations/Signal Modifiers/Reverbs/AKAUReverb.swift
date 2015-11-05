//
//  AKAUReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Reverb Audio Unit */
public class AKAUReverb: AKOperation {
    private let reverbAU = AVAudioUnitReverb()
    
    /** Dry/Wet Mix (Default 50) */
    public var dryWetMix:Float = 50.0 {
        didSet {
            reverbAU.wetDryMix = dryWetMix
        }
    }
    
    /** Initialize the effect operation */
    public init(_ input: AKOperation) {
        super.init()
        output = reverbAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
    
    /** Load an Apple Factory Preset */
    public func loadFactoryPreset(preset: AVAudioUnitReverbPreset) {
        reverbAU.loadFactoryPreset(preset)
    }
    
}