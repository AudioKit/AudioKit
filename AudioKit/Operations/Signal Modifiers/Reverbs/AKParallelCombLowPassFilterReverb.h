//
//  AKParallelCombLowPassFilterReverb.h
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A reverberator consisting of 6 parallel comb-lowpass filters.

 This is a reverberator consisting of 6 parallel comb-lowpass filters being fed into a series of 5 allpass filters.
 */

@interface AKParallelCombLowPassFilterReverb : AKAudio
/// Instantiates the parallel comb low pass filter reverb with all values
/// @param input Audio signal to be reverberated. [Default Value: ]
/// @param duration Length of reverbation in seconds. Updated at Control-rate. [Default Value: 3]
/// @param highFrequencyDiffusivity A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster than lower ones. Updated at Control-rate. [Default Value: 0.5]
- (instancetype)initWithInput:(AKParameter *)input
                     duration:(AKParameter *)duration
     highFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity;

/// Instantiates the parallel comb low pass filter reverb with default values
/// @param input Audio signal to be reverberated.
- (instancetype)initWithInput:(AKParameter *)input;

/// Instantiates the parallel comb low pass filter reverb with default values
/// @param input Audio signal to be reverberated.
+ (instancetype)audioWithInput:(AKParameter *)input;

/// Length of reverbation in seconds. [Default Value: 3]
@property AKParameter *duration;

/// Set an optional duration
/// @param duration Length of reverbation in seconds. Updated at Control-rate. [Default Value: 3]
- (void)setOptionalDuration:(AKParameter *)duration;

/// A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster than lower ones. [Default Value: 0.5]
@property AKParameter *highFrequencyDiffusivity;

/// Set an optional high frequency diffusivity
/// @param highFrequencyDiffusivity A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster than lower ones. Updated at Control-rate. [Default Value: 0.5]
- (void)setOptionalHighFrequencyDiffusivity:(AKParameter *)highFrequencyDiffusivity;



@end
