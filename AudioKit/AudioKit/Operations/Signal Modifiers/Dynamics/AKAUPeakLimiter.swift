//
//  AKAUPeakLimiter.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/30/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's AKAUPeakLimiter Audio Unit */
public class AKAUPeakLimiter: AKOperation {
    
    private let cd:AudioComponentDescription = AudioComponentDescription(componentType: OSType(kAudioUnitType_Effect),componentSubType: OSType(kAudioUnitSubType_PeakLimiter),componentManufacturer: OSType(kAudioUnitManufacturer_Apple),componentFlags: 0,componentFlagsMask: 0)
    
    private var limiterAU = AVAudioUnitEffect()
    public var internalAU = AudioUnit()
    
    /** Attack Time - Range is from 0.001 through 0.03 seconds. Default value is 0.012 s. */
    public var attackTime:Float = 0.012 {
        didSet {
            AudioUnitSetParameter(internalAU, kLimiterParam_AttackTime, kAudioUnitScope_Global, 0, attackTime, 0)
        }
    }//attackTime
    
    /** Decay Time - Range is from 0.001 through 0.06 seconds. Default value is 0.024 s. */
    public var decayTime:Float = 0.024 {
        didSet {
            AudioUnitSetParameter(internalAU, kLimiterParam_DecayTime, kAudioUnitScope_Global, 0, decayTime, 0)
        }
    }//decayTime
    
    /** PreGain - Range is from –40 through +40 dB. Default value is 0 dB. */
    public var pregain:Float = 0 {
        didSet {
            AudioUnitSetParameter(internalAU, kLimiterParam_PreGain, kAudioUnitScope_Global, 0, pregain, 0)
        }
    }//pregain
    
    /** LimitingAmount - Range is from 0 through 20. Default value is 0. */
    public var limitingAmount:Float = 0 {
        didSet {
            AudioUnitSetParameter(internalAU, 1000, kAudioUnitScope_Global, 0, pregain, 0)
        }
    }//pregain
    
    /** Initialize the limiter operation */
    public init(_ input: AKOperation) {
        super.init()
        limiterAU = AVAudioUnitEffect(audioComponentDescription: cd)
        internalAU = limiterAU.audioUnit
        output = limiterAU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
}