//
//  AKLowPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 12/20/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A low-pass Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

@interface AKLowPassButterworthFilter : AKAudio
/// Instantiates the low pass butterworth filter with all values
/// @param audioSource Input signal to be filtered. [Default Value: ]
/// @param cutoffFrequency Cutoff frequency for each of the filters. [Default Value: 1000]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency;

/// Instantiates the low pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the low pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// Cutoff frequency for each of the filters. [Default Value: 1000]
@property AKControl *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Cutoff frequency for each of the filters. [Default Value: 1000]
- (void)setOptionalCutoffFrequency:(AKControl *)cutoffFrequency;



@end
