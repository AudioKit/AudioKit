//
//  OCSEqualizerFilter.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Second-order tunable equalisation filter based on Regalia and Mitra design.
 
 Provides a peak/notch filter for building parametric/graphic equalisers.
 The amplitude response for this filter will be flat (=1) for gain=1. With gain bigger than 1, there will be a peak at the center frequency, whose width is given by the bandwidth parameter, but outside this band, the response will tend towards 1. Conversely, if gain is smaller than 1, a notch will be created around the CF.
 */

@interface OCSEqualizerFilter : OCSAudio

/// Instantiates the equalizer filter
/// @param audioSource     Input signal.
/// @param centerFrequency Filter center frequency in Hz.
/// @param bandwidth       Peak/notch bandwidth in Hz.
/// @param gain            Peak/notch gain.
- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    centerFrequency:(OCSControl *)centerFrequency
                          bandwidth:(OCSControl *)bandwidth
                               gain:(OCSControl *)gain;

@end