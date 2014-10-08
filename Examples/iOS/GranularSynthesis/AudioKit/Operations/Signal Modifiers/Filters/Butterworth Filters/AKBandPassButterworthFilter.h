//
//  AKBandPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A band-pass Butterworth filter.
 
 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

@interface AKBandPassButterworthFilter : AKAudio

/// Instantiates the band pass Butterworth filter
/// @param audioSource     Input signal to be filtered.
/// @param centerFrequency Center frequency for each of the filters.
/// @param bandwidth       Bandwidth of the band-pass filters.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    centerFrequency:(AKControl *)centerFrequency
                          bandwidth:(AKControl *)bandwidth;

@end