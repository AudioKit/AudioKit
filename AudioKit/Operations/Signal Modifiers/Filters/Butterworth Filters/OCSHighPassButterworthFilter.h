//
//  OCSHighPassButterworthFilter.h
//  Objective-C Sound
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A high-pass Butterworth filter.
 
 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

@interface OCSHighPassButterworthFilter : OCSAudio

/// Instantiates the high pass butterworth filter
/// @param audioSource     Input signal to be filtered.
/// @param cutoffFrequency Cutoff frequency for each of the filters.
- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
                    cutoffFrequency:(OCSControl *)cutoffFrequency;

@end