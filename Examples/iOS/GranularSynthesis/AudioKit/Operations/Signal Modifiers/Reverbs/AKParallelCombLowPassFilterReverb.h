//
//  AKParallelCombLowPassFilterReverb.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A reverberator consisting of 6 parallel comb-lowpass filters.
 
 This is a reverberator consisting of 6 parallel comb-lowpass filters being fed into a series of 5 allpass filters.
 */

@interface AKParallelCombLowPassFilterReverb : AKAudio

/// Instantiates the arallel comb low pass filter reverb
/// @param audioSource Audio signal to be reverberated.
/// @param duration Length of reverbation in seconds.
/// @param highFrequencyDiffusivity A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster that lower ones.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                           duration:(AKControl *)duration
           highFrequencyDiffusivity:(AKControl *)highFrequencyDiffusivity;

@end