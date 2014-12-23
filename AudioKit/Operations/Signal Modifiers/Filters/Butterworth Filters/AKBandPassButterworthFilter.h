//
//  AKBandPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 12/20/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A band-pass Butterworth filter.

 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

@interface AKBandPassButterworthFilter : AKAudio
/// Instantiates the band pass butterworth filter with all values
/// @param audioSource Input signal to be filtered. [Default Value: ]
/// @param centerFrequency Center frequency for each of the filters. [Default Value: 2000]
/// @param bandwidth Bandwidth of the band-pass filters. [Default Value: 100]
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth;

/// Instantiates the band pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;

/// Instantiates the band pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
+ (instancetype)audioWithAudioSource:(AKAudio *)audioSource;
/// Center frequency for each of the filters. [Default Value: 2000]
@property AKControl *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Center frequency for each of the filters. [Default Value: 2000]
- (void)setOptionalCenterFrequency:(AKControl *)centerFrequency;
/// Bandwidth of the band-pass filters. [Default Value: 100]
@property AKControl *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the band-pass filters. [Default Value: 100]
- (void)setOptionalBandwidth:(AKControl *)bandwidth;



@end
