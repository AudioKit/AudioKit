//
//  AKAURingModulator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 11/6/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import AVFoundation

/** AudioKit version of Apple's Ring Modulator from the Distortion Audio Unit */
public class AKAURingModulator: AKOperation {
    
    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_Distortion,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)
    
    private var internalEffect = AVAudioUnitEffect()
    private var internalAU = AudioUnit()
    
    /** Frequency1 (Hertz) ranges from 0.5 to 8000 (Default: 100) */
    public var frequency1: Float = 100 {
        didSet {
            if frequency1 < 0.5 {
                frequency1 = 0.5
            }
            if frequency1 > 8000 {
                frequency1 = 8000
            }
            AudioUnitSetParameter(internalAU, kDistortionParam_RingModFreq1, kAudioUnitScope_Global, 0, frequency1, 0)
        }
    }
    
    /** Frequency2 (Hertz) ranges from 0.5 to 8000 (Default: 100) */
    public var frequency2: Float = 100 {
        didSet {
            if frequency2 < 0.5 {
                frequency2 = 0.5
            }
            if frequency2 > 8000 {
                frequency2 = 8000
            }
            AudioUnitSetParameter(internalAU, kDistortionParam_RingModFreq2, kAudioUnitScope_Global, 0, frequency2, 0)
        }
    }
    
    /** Balance (Percent) ranges from 0 to 100 (Default: 50) */
    public var balance: Float = 50 {
        didSet {
            if balance < 0 {
                balance = 0
            }
            if balance > 100 {
                balance = 100
            }
            AudioUnitSetParameter(internalAU, kDistortionParam_RingModBalance, kAudioUnitScope_Global, 0, balance, 0)
        }
    }
    
    /** Mix (Percent) ranges from 0 to 100 (Default: 50) */
    public var mix: Float = 50 {
        didSet {
            if mix < 0 {
                mix = 0
            }
            if mix > 100 {
                mix = 100
            }
            AudioUnitSetParameter(internalAU, kDistortionParam_FinalMix, kAudioUnitScope_Global, 0, mix, 0)
        }
    }
    
    /** Initialize the effect operation */
    public init(
        _ input: AKOperation,
        frequency1: Float = 100,
        frequency2: Float = 100,
        balance: Float = 50,
        mix: Float = 0)
    {
        self.frequency1 = frequency1
        self.frequency2 = frequency2
        self.balance = balance
        self.mix = mix
        super.init()

        internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
        output = internalEffect
        AKManager.sharedInstance.engine.attachNode(internalEffect)
        AKManager.sharedInstance.engine.connect(input.output!, to: internalEffect, format: nil)
        internalAU = internalEffect.audioUnit
        
        // Since this is the Ring Modulator, mix it to 100% and use the final mix as the mix parameter
        AudioUnitSetParameter(internalAU, kDistortionParam_RingModMix, kAudioUnitScope_Global, 0, 100, 0)
    }
}