//
//  AKResonantFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/21/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A second-order resonant filter.

 This is a second-order filter defined by a center frequency which is the frequency position of the peak response, and a bandwidth which is the frequency difference between the upper and lower half-power points.
 */

@interface AKResonantFilter : AKAudio
/// Instantiates the resonant filter with all values
/// @param audioSource The input audio stream. [Default Value: ]
/// @param centerFrequency Center frequency of the filter, or frequency position of the peak response. [Default Value: 1000]
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth;

/// Instantiates the resonant filter with default values
/// @param audioSource The input audio stream.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the resonant filter with default values
/// @param audioSource The input audio stream.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// Center frequency of the filter, or frequency position of the peak response. [Default Value: 1000]
@property AKControl *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Center frequency of the filter, or frequency position of the peak response. [Default Value: 1000]
- (void)setOptionalCenterFrequency:(AKControl *)centerFrequency;
/// Bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
@property AKControl *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the filter (the Hz difference between the upper and lower half-power points). [Default Value: 10]
- (void)setOptionalBandwidth:(AKControl *)bandwidth;



@end
