//
//  OCSReverbSixParallelComb.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

//ares nreverb asig, ktime, khdif [, iskip] [,inumCombs] [, ifnCombs] \
[, inumAlpas] [, ifnAlpas]
@interface OCSReverbSixParallelComb : OCSOpcode
{
    OCSParam *output;
    OCSParam *input;
    OCSParamControl *reverbDuration;
    OCSParamControl *highFreqeuncyDiffusionAmount;
    
    BOOL isInitSkipped;
    
    NSArray *combFilterTimeValues;
    NSArray *combFilterGainValues;
    
    NSArray *allPassFilterTimeValues;
    NSArray *allPassFilterGainValues;
}

@property (nonatomic, strong) OCSParam *output;

- (id)initWithInput:(OCSParam *) in
ReverbDuration:(OCSParamControl *) dur
HighFrequencyDiffustionAmount:(OCSParamControl *) freqDiff;

- (id)initWithInput:(OCSParam *) in
ReverbDuration:(OCSParamControl *) dur
HighFrequencyDiffustionAmount:(OCSParamControl *) freqDiff
CombFilterTimeValues:(NSArray *)combTime
CombFilterGainValues:(NSArray *)combGain
AllPassFilterTimeValues:(NSArray *)allPassTime
AllPassFilterGainValues:(NSArray *)allPassGain
SkipInit:(BOOL)isSkipped;

@end
