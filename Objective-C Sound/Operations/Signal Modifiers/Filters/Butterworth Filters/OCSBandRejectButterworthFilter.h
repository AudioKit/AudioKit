//
//  OCSBandRejectButterworthFilter.h
//  Objective-C Sound
//
//  Created by Adam Boulanger on 9/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A second-order band-reject Butterworth filter. These filters are Butterworth second-order IIR filters.
 They are slightly slower than the original filters in Csound, but they offer an almost flat
 passband and very good precision and stopband attenuation.
 */

@interface OCSBandRejectButterworthFilter : OCSAudio

/// Creates a band-reject Butterworth filter.
/// @param audioSource     The input to be filtered.
/// @param centerFrequency Center frequency for each of the filters.
/// @param bandwidthRange  Bandwidth of the bandreject filter.
-(instancetype)initWithAudioSource:(OCSAudio *)audioSource
                   centerFrequency:(OCSControl *)centerFrequency
                         bandwidth:(OCSControl *)bandwidthRange;


@end
