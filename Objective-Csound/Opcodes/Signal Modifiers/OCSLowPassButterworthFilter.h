//
//  OCSLowPassButterworthFilter.h
//  Objective-Csound
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** A second-order low-pass Butterworth filter. These filters are Butterworth second-order IIR filters. 
 They are slightly slower than the original filters in Csound, but they offer an almost flat 
 passband and very good precision and stopband attenuation.
 */
 
@interface OCSLowPassButterworthFilter : OCSOpcode

/// @name Properties

/// The output is a mono audio signal.
@property (nonatomic, retain) OCSParameter *output;

/// @name Initialization

/// Creates a low-pass Butterworth filter.
/// @param inputSignal     The input to be filtered.
/// @param cutoffFrequency Cutoff or center frequency for each of the filters.
-(id)initWithInput:(OCSParameter *)inputSignal 
   cutoffFrequency:(OCSControl *)cutoffFrequency;

@end
