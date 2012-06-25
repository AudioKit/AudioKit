//
//  OCSFilterLowPassButter.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** A low-pass Butterworth filter.
 
 These filters are Butterworth second-order IIR filters. They are slightly slower than the original filters in Csound, but they offer an almost flat passband and very good precision and stopband attenuation.
 
 */
 
@interface OCSFilterLowPassButterworth : OCSOpcode
@property (nonatomic, retain) OCSParam *output;

/// Initialization Statement
-(id)initWithInput:(OCSParam *)i Cutoff:(OCSParamControl *)freq;

/// Initialization Statement
-(id)initWithInput:(OCSParam *)i Cutoff:(OCSParamControl *)freq SkipInit:(BOOL)isSkipped;

@end
