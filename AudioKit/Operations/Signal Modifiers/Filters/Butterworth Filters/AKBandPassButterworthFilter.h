//
//  AKBandPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated on 12/23/14.
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
/// @param centerFrequency Center frequency for each of the filters. Updated at Control-rate. [Default Value: 2000]
/// @param bandwidth Bandwidth of the band-pass filters. Updated at Control-rate. [Default Value: 100]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    centerFrequency:(AKParameter *)centerFrequency
                          bandwidth:(AKParameter *)bandwidth;

/// Instantiates the band pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

/// Instantiates the band pass butterworth filter with default values
/// @param audioSource Input signal to be filtered.
+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource;

/// Center frequency for each of the filters. [Default Value: 2000]
@property AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Center frequency for each of the filters. Updated at Control-rate. [Default Value: 2000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// Bandwidth of the band-pass filters. [Default Value: 100]
@property AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Bandwidth of the band-pass filters. Updated at Control-rate. [Default Value: 100]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;



@end
