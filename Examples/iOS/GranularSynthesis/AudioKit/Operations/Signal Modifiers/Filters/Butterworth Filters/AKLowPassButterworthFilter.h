//
//  AKLowPassButterworthFilter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/26/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A low-pass Butterworth filter.
 
 These filters are Butterworth second-order IIR filters. They offer an almost flat passband and very good precision and stopband attenuation.
 */

@interface AKLowPassButterworthFilter : AKAudio

/// Instantiates the low pass butterworth filter
/// @param audioSource     Input signal to be filtered.
/// @param cutoffFrequency Cutoff frequency for each of the filters.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKControl *)cutoffFrequency;

@end