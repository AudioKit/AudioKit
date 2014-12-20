//
//  AKHighPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/20/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A high-pass Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

@interface AKHighPassButterworthFilter : AKAudio
/// Instantiates the high pass butterworth filter with all values
/// @param audioSource Input signal to be filtered. [Default Value: ]
/// @param cutoffFrequency Cutoff frequency for each of the filters. [Default Value: 500]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency;

/// Instantiates the high pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the high pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// Cutoff frequency for each of the filters. [Default Value: 500]
@property AKControl *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Cutoff frequency for each of the filters. [Default Value: 500]
- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency;



@end
