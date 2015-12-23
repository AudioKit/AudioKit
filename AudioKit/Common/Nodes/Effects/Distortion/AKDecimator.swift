//
//  AKDecimator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

/** AudioKit version of Apple's Distortion Audio Unit */
public struct AKDecimator: AKNode {
    
    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Distortion,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)
    
    private var internalEffect = AVAudioUnitEffect()
    public var internalAudioUnit = AudioUnit()
    public var avAudioNode: AVAudioNode
    
    /** Decimation (Percent) ranges from 0 to 100 (Default: 50) */
    public var decimation: Double = 50 {
        didSet {
            if decimation < 0 {
                decimation = 0
            }
            if decimation > 100 {
                decimation = 100
            }
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_Decimation, kAudioUnitScope_Global, 0, Float(decimation), 0)
        }
    }
    
    /** Rounding (Percent) ranges from 0 to 100 (Default: 0) */
    public var rounding: Double = 0 {
        didSet {
            if rounding < 0 {
                rounding = 0
            }
            if rounding > 100 {
                rounding = 100
            }
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_Rounding, kAudioUnitScope_Global, 0, Float(rounding), 0)
        }
    }
    
        
    /** Mix (Percent) ranges from 0 to 100 (Default: 50) */
    public var mix: Double = 50 {
        didSet {
            if mix < 0 {
                mix = 0
            }
            if mix > 100 {
                mix = 100
            }
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, Float(mix), 0)
        }
    }
    
    /** Initialize the effect node */
    public init(
        _ input: AKNode,
        decimation: Double = 50,
        rounding: Double = 0,
        mix: Double = 50) {
            
            self.decimation = decimation
            self.rounding = rounding
            self.mix = mix
            
            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            self.avAudioNode = internalEffect
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            AKManager.sharedInstance.engine.connect(input.avAudioNode, to: self.avAudioNode, format: AKManager.format)
            internalAudioUnit = internalEffect.audioUnit
            
            // Since this is the Decimator, mix it to 100% and use the final mix as the mix parameter
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_DecimationMix, kAudioUnitScope_Global, 0, 100, 0)
            
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_Decimation, kAudioUnitScope_Global, 0, Float(decimation), 0)
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_Rounding, kAudioUnitScope_Global, 0, Float(rounding), 0)
            AudioUnitSetParameter(internalAudioUnit, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, Float(mix), 0)
    }
}
