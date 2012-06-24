//
//  OCSReverbSixParallelComb.h
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

//ares nreverb asig, ktime, khdif [, iskip] [,inumCombs] [, ifnCombs] [, inumAlpas] [, ifnAlpas]
@interface OCSReverbSixParallelComb : OCSOpcode
{
    OCSParam *output;
    OCSParam *input;
    OCSParamControl *reverbDuration;
    OCSParamControl *highFrequencyDiffusivity;
    
    BOOL isInitSkipped;
    
    NSArray *combFilterTimes;
    NSArray *combFilterGains;
    
    NSArray *allPassFilterTimes;
    NSArray *allPassFilterGains;
}

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
