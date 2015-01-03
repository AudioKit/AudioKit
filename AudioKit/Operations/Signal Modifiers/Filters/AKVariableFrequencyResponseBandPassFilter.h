//
//  AKVariableFrequencyResponseBandPassFilter.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A second-order resonant filter.

 This is a second-order filter defined by a center frequency which is the frequency position of the peak response, and a bandwidth which is the frequency difference between the upper and lower half-power points.
 */

@interface AKVariableFrequencyResponseBandPassFilter : AKAudio
/// Instantiates the variable frequency response band pass filter with all values
/// @param audioSource The input signal to be filtered. [Default Value: ]
/// @param cutoffFrequency Cutoff or resonant frequency of the filter, measured in Hz. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          bandwidth:(AKParameter *)bandwidth;

/// Instantiates the variable frequency response band pass filter with default values
/// @param audioSource The input signal to be filtered.
- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

/// Instantiates the variable frequency response band pass filter with default values
/// @param audioSource The input signal to be filtered.
+ (instancetype)filterWithAudioSource:(AKParameter *)audioSource;

/// Cutoff or resonant frequency of the filter, measured in Hz. [Default Value: 1000]
@property AKParameter *cutoffFrequency;

/// Set an optional cutoff frequency
/// @param cutoffFrequency Cutoff or resonant frequency of the filter, measured in Hz. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency;

/// Bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
@property AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). Updated at Control-rate. [Default Value: 10]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;



@end
