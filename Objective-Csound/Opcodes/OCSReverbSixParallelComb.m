//
//  OCSReverbSixParallelComb.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSReverbSixParallelComb.h"

@implementation OCSReverbSixParallelComb
@synthesize output;

- (id)initWithInput:(OCSParam *) in
ReverbDuration:(OCSParamControl *) dur
HighFrequencyDiffustionAmount:(OCSParamControl *) freqDiff
{
self = [super init];
if(self) {
    output = [OCSParam paramWithFormat:[self opcodeName]];
    input = in;
    reverbDuration = dur;
    highFreqeuncyDiffusionAmount = freqDiff;
}
return self;
}

- (id)initWithInput:(OCSParam *) in
ReverbDuration:(OCSParamControl *) dur
HighFrequencyDiffustionAmount:(OCSParamControl *) freqDiff
CombFilterTimeValues:(NSArray *)combTime
CombFilterGainValues:(NSArray *)combGain
AllPassFilterTimeValues:(NSArray *)allPassTime
AllPassFilterGainValues:(NSArray *)allPassGain
SkipInit:(BOOL)isSkipped
{
self = [super init];
if(self) {
    output = [OCSParam paramWithFormat:[self opcodeName]];
    input = in;
    reverbDuration = dur;
    highFreqeuncyDiffusionAmount = freqDiff;
    
    combFilterTimeValues = combTime;
    combFilterGainValues = combGain;
    allPassFilterTimeValues = allPassTime;
    allPassFilterGainValues = allPassGain;
    isInitSkipped = isSkipped;
}
return self;
}

- (NSString *)convertToOCS
{
    //iSine ftgentmp 0, 0, 4096, 10, 1
    
    //Check if optional parameters have been set before constructing OCS
    if (combFilterGainValues) {
        
        return [NSString stringWithFormat:@"%@ %@ nreverb %@, %@, %@, %@, %@, %@, %@, %@",
                [self functionTableOCSFromFilterParams],
                output, reverbDuration, highFreqeuncyDiffusionAmount, 
                isInitSkipped, combFilterTimeValues, combFilterGainValues, allPassFilterTimeValues,
                allPassFilterGainValues];
    } else {
        return [NSString stringWithFormat:@"%@ nreverb %@, %@, %@", 
                output, reverbDuration, highFreqeuncyDiffusionAmount];
    }
}

- (NSString *)functionTableOCSFromFilterParams
{
    NSString *combTable = [NSString stringWithFormat:@"%i%@CombValues ftgentmp 0, 0, %i, %@ %@\n",
                            [self opcodeName], [combFilterGainValues count], -2, combFilterTimeValues, combFilterGainValues]; 
    NSString *allPassTable = [NSString stringWithFormat:@"%i%@CombValues ftgentmp 0, 0, %i, %@ %@\n",
                               [self opcodeName], [allPassFilterGainValues count], -2, allPassFilterTimeValues, allPassFilterGainValues]; 
    NSString *s = [NSString stringWithFormat:@"%@ %@", combTable, allPassTable];
    return s;
}

- (NSString *)description {
    return [output parameterString];
}

@end
