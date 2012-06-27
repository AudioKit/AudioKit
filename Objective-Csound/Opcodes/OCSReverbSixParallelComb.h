//
//  OCSReverbSixParallelComb.h
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** This is a reverberator consisting of 6 parallel comb-lowpass filters 
 being fed into a series of 5 allpass filters. 
 */

//ares nreverb asig, ktime, khdif [, iskip] [,inumCombs] [, ifnCombs] [, inumAlpas] [, ifnAlpas]
@interface OCSReverbSixParallelComb : OCSOpcode

/// The output is a mono audio signal.
@property (nonatomic, strong) OCSParam *output;

- (id)initWithInput:(OCSParam *)i
     ReverbDuration:(OCSParamControl *)dur 
HighFreqDiffusivity:(OCSParamControl *)hfdif;

- (id)initWithInput:(OCSParam *)i
     ReverbDuration:(OCSParamControl *)dur
HighFreqDiffusivity:(OCSParamControl *)hfdif
    CombFilterTimes:(NSArray *)combTime
    CombFilterGains:(NSArray *)combGain
 AllPassFilterTimes:(NSArray *)allPassTime
 AllPassFilterGains:(NSArray *)allPassGain
           SkipInit:(BOOL)isSkipped;

@end
