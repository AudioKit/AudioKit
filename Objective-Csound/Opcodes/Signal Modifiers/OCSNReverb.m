//
//  OCSNReverb.m
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNReverb.h"

@interface OCSNReverb () {
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
@end


@implementation OCSNReverb
@synthesize output;

- (id)initWithInput:(OCSParam *)i
     reverbDuration:(OCSParamControl *)dur 
highFreqDiffusivity:(OCSParamControl *)hfdif;
{
    self = [super init];
    if(self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        input = i;
        reverbDuration = dur;
        highFrequencyDiffusivity = hfdif;
    }
    return self;
}

- (id)initWithInput:(OCSParam *)i
     reverbDuration:(OCSParamControl *)dur
highFreqDiffusivity:(OCSParamControl *)hfdif
    combFilterTimes:(NSArray *)combTime
    combFilterGains:(NSArray *)combGain
 allPassFilterTimes:(NSArray *)allPassTime
 allPassFilterGains:(NSArray *)allPassGain;
{
    self = [super init];
    if(self) {
        output = [OCSParam paramWithString:[self opcodeName]];
        input = i;
        reverbDuration = dur;
        highFrequencyDiffusivity = hfdif;
        
        combFilterTimes = combTime;
        combFilterGains = combGain;
        allPassFilterTimes = allPassTime;
        allPassFilterGains = allPassGain;
    }
    return self;
}

- (NSString *)stringForCSD
{
    //iSine ftgentmp 0, 0, 4096, 10, 1
    
    //Check if optional parameters have been set before constructing CSD

    if (combFilterGains) {
        return [NSString stringWithFormat:@"%@ %@ nreverb %@, %@, %@, %@, %@, %@, %@\n",
                [self functionTableCSDFromFilterParams],
                output, reverbDuration, highFrequencyDiffusivity, 
                combFilterTimes, combFilterGains, allPassFilterTimes,
                allPassFilterGains];
    } else {
        return [NSString stringWithFormat:@"%@ nreverb %@, %@, %@\n", 
                output, input, reverbDuration, highFrequencyDiffusivity];
    }
}

- (NSString *)functionTableCSDFromFilterParams
{
    NSString *combTable = [NSString stringWithFormat:@"%i%@CombValues ftgentmp 0, 0, %i, %@ %@\n",
                           [self opcodeName], [combFilterGains count], -2, combFilterTimes, combFilterGains]; 
    NSString *allPassTable = [NSString stringWithFormat:@"%i%@CombValues ftgentmp 0, 0, %i, %@ %@\n",
                              [self opcodeName], [allPassFilterGains count], -2, allPassFilterTimes, allPassFilterGains]; 
    NSString *s = [NSString stringWithFormat:@"%@ %@", combTable, allPassTable];
    return s;
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
