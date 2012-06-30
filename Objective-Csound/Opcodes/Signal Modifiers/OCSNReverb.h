//
//  OCSNReverb.h
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSNReverb.h"

/** This is a reverberator consisting of 6 parallel comb-lowpass filters 
 being fed into a series of 5 allpass filters. 
 */

//ares nreverb asig, ktime, khdif [, iskip] [,inumCombs] [, ifnCombs] [, inumAlpas] [, ifnAlpas]
@interface OCSNReverb : OCSOpcode

/// The output is a mono audio signal.
@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
- (id)initWithInput:(OCSParam *)i
     reverbDuration:(OCSParamControl *)dur 
highFreqDiffusivity:(OCSParamControl *)hfdif;

/// Initialization Statement
- (id)initWithInput:(OCSParam *)i
     reverbDuration:(OCSParamControl *)dur
highFreqDiffusivity:(OCSParamControl *)hfdif
    combFilterTimes:(NSArray *)combTime
    combFilterGains:(NSArray *)combGain
 allPassFilterTimes:(NSArray *)allPassTime
 allPassFilterGains:(NSArray *)allPassGain;

@end
