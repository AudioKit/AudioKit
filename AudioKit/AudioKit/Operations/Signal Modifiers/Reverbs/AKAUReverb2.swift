//
//  AKAUReverb2.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/30/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/** AudioKit version of Apple's Reverb2 Audio Unit */
public class AKAUReverb2: AKOperation {
    
    private let cd:AudioComponentDescription = AudioComponentDescription(componentType: OSType(kAudioUnitType_Effect),componentSubType: OSType(kAudioUnitSubType_Reverb2),componentManufacturer: OSType(kAudioUnitManufacturer_Apple),componentFlags: 0,componentFlagsMask: 0)
    
    private var reverb2AU = AVAudioUnitEffect()
    
    /** internalAU - Access to the AudioUnit itself */
    public var internalAU = AudioUnit()
    
    /** Wet/Dry Mix 
    Default value is 50 */
    public var dryWetMix:Float = 50.0 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0,
                dryWetMix, 0)
        }
    }//wtDryMix
    
    /** Gain (Default 0 dB) Range is from –20 through +20 dB. 
    Default value is 0 dB. */
    public var gain:Float = 0 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_Gain, kAudioUnitScope_Global, 0,
                gain, 0)
        }
    }//gain
    
    /** MinDelayTime (predelay in seconds) - Range is from 0.0001 through 1.0 seconds. 
    Default value is 0.008 s */
    public var minDelayTime:Float = 0.008 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0,
                minDelayTime, 0)
        }
    }//minDelayTime
    
    /** MaxDelayTime (predelay in seconds) - Range is from 0.0001 through 1.0 seconds. 
    Default value is 0.050 s */
    public var maxDelayTime:Float = 0.008 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0,
                maxDelayTime, 0)
        }
    }//maxDelayTime
    
    /** Verb Duration - affects all frequencies decay times
    Range is from 0.001 through 20.0 seconds
    For individual control, use decayTimeAt0hz and decayTimeAtNyquist
    Default value is 3.03 */
    public var reverbDuration:Float = 3.03 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0,
                reverbDuration, 0)
            AudioUnitSetParameter(internalAU, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0,
                reverbDuration, 0)
        }
    }//reverbDuration
    
    /** DecayTimeAt0Hz - decay time for low frequencies
    Range is from 0.001 through 20.0 seconds
    Default value is 3.03 */
    public var decayTimeAt0Hz:Float = 3.03 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_DecayTimeAt0Hz, kAudioUnitScope_Global, 0,
                decayTimeAt0Hz, 0)
        }
    }//decayTimeAt0Hz
    
    /** DecayTimeAtNyquist - decay time for high frequencies
    Range is from 0.001 through 20.0 seconds
    Default value is 3.03 */
    public var decayTimeAtNyquist:Float = 3.03 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_DecayTimeAtNyquist, kAudioUnitScope_Global, 0,
                decayTimeAtNyquist, 0)
        }
    }//decayTimeAtNyquist
    
    /** randomizeRefelctions - Range is from 1 through 1000 (unitless)
    Default value is 1 */
    public var reandomizeReflections:Float = 1 {
        didSet {
            AudioUnitSetParameter(internalAU, kReverb2Param_RandomizeReflections, kAudioUnitScope_Global, 0, reandomizeReflections, 0)
        }
    }//randomizeRefelections
    
    /** Initialize the reverb operation */
    public init(_ input: AKOperation) {
        super.init()
        reverb2AU = AVAudioUnitEffect(audioComponentDescription: cd)
        internalAU = reverb2AU.audioUnit
        output = reverb2AU
        AKManager.sharedInstance.engine.attachNode(output!)
        AKManager.sharedInstance.engine.connect(input.output!, to: output!, format: nil)
    }
    
    
}