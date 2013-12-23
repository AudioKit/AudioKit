//
//  OCSLowPassButterworthFilter.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A second-order low-pass Butterworth filter. These filters are Butterworth second-order IIR filters.
 They are slightly slower than the original filters in Csound, but they offer an almost flat
 passband and very good precision and stopband attenuation.
 */

@interface OCSLowPassButterworthFilter : OCSAudio

/// Creates a low-pass Butterworth filter.
/// @param audioSource     The input to be filtered.
/// @param cutoffFrequency Cutoff of the lowpass filter.
-(instancetype)initWithAudioSource:(OCSAudio *)audioSource
                   cutoffFrequency:(OCSControl *)cutoffFrequency;

@end
