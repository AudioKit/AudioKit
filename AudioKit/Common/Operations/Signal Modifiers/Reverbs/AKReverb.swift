//
//  AKReverb.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/4/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Reverb Audio Unit */
public class AKReverb: AKOperation {
    private let reverbAU = AVAudioUnitReverb()
    
    /** Dry/Wet Mix (Default 50) */
    public var dryWetMix: Float = 50.0 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            reverbAU.wetDryMix = dryWetMix
        }
    }
    
    /** Initialize the reverb operation */
    public init(_ input: AKOperation, dryWetMix: Float = 50) {
        self.dryWetMix = dryWetMix
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
