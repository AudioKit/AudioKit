//
//  AKParallelCombLowPassFilterReverb.h
//  AudioKit
//
//  Auto-generated on 12/19/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A reverberator consisting of 6 parallel comb-lowpass filters.

 This is a reverberator consisting of 6 parallel comb-lowpass filters being fed into a series of 5 allpass filters.
 */

@interface AKParallelCombLowPassFilterReverb : AKAudio
/// Instantiates the parallel comb low pass filter reverb with all values
/// @param audioSource Audio signal to be reverberated. [Default Value: ]
/// @param duration Length of reverbation in seconds. [Default Value: 3]
/// @param highFrequencyDiffusivity A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster than lower ones. [Default Value: 0.5]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                           duration:(AKControl *)duration
           highFrequencyDiffusivity:(AKControl *)highFrequencyDiffusivity;

/// Instantiates the parallel comb low pass filter reverb with default values
/// @param audioSource Audio signal to be reverberated.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the parallel comb low pass filter reverb with default values
/// @param audioSource Audio signal to be reverberated.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// Length of reverbation in seconds. [Default Value: 3]
@property AKControl *duration;

/// Set an optional duration
/// @param duration Length of reverbation in seconds. [Default Value: 3]
- (void)setOptionalDuration:(AKControl *)duration;
/// A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster than lower ones. [Default Value: 0.5]
@property AKControl *highFrequencyDiffusivity;

/// Set an optional high frequency diffusivity
/// @param highFrequencyDiffusivity A value between 0 and 1.  At 0, all frequencies decay with the same speed.  At 1, high frequencies decay faster than lower ones. [Default Value: 0.5]
- (void)setOptionalHighFrequencyDiffusivity:(AKControl *)highFrequencyDiffusivity;



@end
