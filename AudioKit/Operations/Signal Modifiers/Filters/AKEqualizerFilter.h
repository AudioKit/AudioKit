//
//  AKEqualizerFilter.h
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Second-order tunable equalisation filter based on Regalia and Mitra design.

 Provides a peak/notch filter for building parametric/graphic equalisers.
The amplitude response for this filter will be flat (=1) for gain=1. With gain bigger than 1, there will be a peak at the center frequency, whose width is given by the bandwidth parameter, but outside this band, the response will tend towards 1. Conversely, if gain is smaller than 1, a notch will be created around the CF.
 */

@interface AKEqualizerFilter : AKAudio
/// Instantiates the equalizer filter with all values
/// @param audioSource Input signal. [Default Value: ]
/// @param centerFrequency Filter center frequency in Hz. Updated at Control-rate. [Default Value: 1000]
/// @param bandwidth Peak/notch bandwidth in Hz. Updated at Control-rate. [Default Value: 100]
/// @param gain Peak/notch gain. Updated at Control-rate. [Default Value: 10]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                    centerFrequency:(AKParameter *)centerFrequency
                          bandwidth:(AKParameter *)bandwidth
                               gain:(AKParameter *)gain;

/// Instantiates the equalizer filter with default values
/// @param audioSource Input signal.
- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

/// Instantiates the equalizer filter with default values
/// @param audioSource Input signal.
+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource;

/// Filter center frequency in Hz. [Default Value: 1000]
@property AKParameter *centerFrequency;

/// Set an optional center frequency
/// @param centerFrequency Filter center frequency in Hz. Updated at Control-rate. [Default Value: 1000]
- (void)setOptionalCenterFrequency:(AKParameter *)centerFrequency;

/// Peak/notch bandwidth in Hz. [Default Value: 100]
@property AKParameter *bandwidth;

/// Set an optional bandwidth
/// @param bandwidth Peak/notch bandwidth in Hz. Updated at Control-rate. [Default Value: 100]
- (void)setOptionalBandwidth:(AKParameter *)bandwidth;

/// Peak/notch gain. [Default Value: 10]
@property AKParameter *gain;

/// Set an optional gain
/// @param gain Peak/notch gain. Updated at Control-rate. [Default Value: 10]
- (void)setOptionalGain:(AKParameter *)gain;



@end
