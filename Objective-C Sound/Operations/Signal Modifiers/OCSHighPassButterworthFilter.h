//
//  OCSHighPassButterworthFilter.h
//  Sonification
//
//  Created by Adam Boulanger on 10/10/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A second-order high-pass Butterworth filter. These filters are Butterworth second-order IIR filters.
 They are slightly slower than the original filters in Csound, but they offer an almost flat
 passband and very good precision and stopband attenuation.
 */

@interface OCSHighPassButterworthFilter : OCSAudio

/// Creates a low-pass Butterworth filter.
/// @param inputSignal     The input to be filtered.
/// @param cutoffFrequency Cutoff of the lowpass filter.
-(id)initWithInput:(OCSParameter *)inputSignal
   cutoffFrequency:(OCSControl *)cutoffFrequency;

@end

