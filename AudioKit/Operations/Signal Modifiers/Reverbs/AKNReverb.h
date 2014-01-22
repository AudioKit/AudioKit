//
//  AKNReverb.h
//  AudioKit
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"
#import "AKNReverb.h"

/** This is a reverberator consisting of 6 parallel comb-lowpass filters
 being fed into a series of 5 allpass filters.
 */

@interface AKNReverb : AKAudio

/// Creates a reverberator consisting of 6 parallel comb-lowpass filters.
/// @param audioSource          Audio signal to be reverberated.
/// @param reverbDuration       Length of reverbation in seconds.
/// @param highFreqDiffusivity  A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster that lower ones.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     reverbDuration:(AKControl *)reverbDuration
                highFreqDiffusivity:(AKControl *)highFreqDiffusivity;

/// Creates a reverberator consisting of 6 parallel comb-lowpass filters.
/// @param audioSource          Audio signal to be reverberated.
/// @param reverbDuration       Length of reverbation in seconds.
/// @param highFreqDiffusivity  A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster that lower ones.
/// @param combFilterTimes      An array of times for the comb filter.
/// @param combFilterGains      An array of gains at each time in the comb filter.
/// @param allPassFilterTimes   An array of times for the all pass filter.
/// @param allPassFilterGains   An array of gains at each time the all pass filter.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     reverbDuration:(AKControl *)reverbDuration
                highFreqDiffusivity:(AKControl *)highFreqDiffusivity
                    combFilterTimes:(NSArray *)combFilterTimes
                    combFilterGains:(NSArray *)combFilterGains
                 allPassFilterTimes:(NSArray *)allPassFilterTimes
                 allPassFilterGains:(NSArray *)allPassFilterGains;

@end
