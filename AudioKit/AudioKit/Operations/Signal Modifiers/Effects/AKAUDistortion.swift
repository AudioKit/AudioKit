//
//  AKAUDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/2/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Distortion Audio Unit */
public class AKAUDistortion: AKOperation {
    
    private let cd = AudioComponentDescription(
        componentType: OSType(kAudioUnitType_Effect),
        componentSubType: OSType(kAudioUnitSubType_Distortion),
        componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
        componentFlags: 0,
        componentFlagsMask: 0)
    
    private var distortionAU = AVAudioUnitEffect()
    public var internalAU = AudioUnit()
    
    /** Decay */
    public var decay: Float = 0.0 {
        didSet {
            AudioUnitSetParameter(internalAU, kDistortionParam_Decay, kAudioUnitScope_Global, 0, decay, 0)
        }
    }
    
    /** Delay */
    public var delay: Float = 0.0 {
        didSet {
            AudioUnitSetParameter(internalAU, kDistortionParam_Delay, kAudioUnitScope_Global, 0, delay, 0)
        }
    }
    
    /** Delay Mix */
    public var delayMix: Float = 0.0 {
        didSet {
            AudioUnitSetParameter(internalAU, kDistortionParam_DelayMix, kAudioUnitScope_Global, 0, delayMix, 0)
        }
    }
    
    /** Final Mix */
    public var finalMix: Float = 0.0 {
        didSet {
            AudioUnitSetParameter(internalAU, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, finalMix, 0)
        }
    }
    
    /** Initialize the reverb operation */
    public init(_ input: AKOperation) {
        super.init()
        distortionAU = AVAudioUnitEffect(audioComponentDescription: cd)
        output = distortionAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
        internalAU = distortionAU.audioUnit
    }
    
    
}