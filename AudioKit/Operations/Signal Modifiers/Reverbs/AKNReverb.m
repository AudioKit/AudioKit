//
//  AKNReverb.m
//  AudioKit
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKNReverb.h"

@interface AKNReverb () {
    AKAudio *input;
    AKControl *dur;
    AKControl *hfdif;
    
    BOOL isInitSkipped;
    
    NSArray *combTimes;
    NSArray *combGains;
    
    NSArray *allPassTimes;
    NSArray *allPassGains;
}
@end


@implementation AKNReverb

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     reverbDuration:(AKControl *)reverbDuration
                highFreqDiffusivity:(AKControl *)highFreqDiffusivity
{
    self = [super initWithString:[self operationName]];
    if(self) {
        input = audioSource;
        dur = reverbDuration;
        hfdif = highFreqDiffusivity;
    }
    return self;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                     reverbDuration:(AKControl *)reverbDuration
                highFreqDiffusivity:(AKControl *)highFreqDiffusivity
                    combFilterTimes:(NSArray *)combFilterTimes
                    combFilterGains:(NSArray *)combFilterGains
                 allPassFilterTimes:(NSArray *)allPassFilterTimes
                 allPassFilterGains:(NSArray *)allPassFilterGains
{
    self = [super initWithString:[self operationName]];
    if(self) {
        input = audioSource;
        dur = reverbDuration;
        hfdif = highFreqDiffusivity;
        
        combTimes = combFilterTimes;
        combGains = combFilterGains;
        allPassTimes = allPassFilterTimes;
        allPassGains = allPassFilterGains;
    }
    return self;
}

//Csound Prototype: aRes nreverb asig, ktime, khdif [, iskip] [,inumCombs] [, ifnCombs] [, inumAlpas] [, ifnAlpas]
- (NSString *)stringForCSD
{
    //iSine ftgentmp 0, 0, 4096, 10, 1
    
    //Check if optional parameters have been set before constructing CSD
    
    if (combGains) {
        return [NSString stringWithFormat:@"%@ nreverb %@, %@, %@, %@, %@, %@, %@",
                [self fTableCSDFromFilterParams],
                self, dur, hfdif, combTimes, combGains, allPassTimes, allPassGains];
    } else {
        return [NSString stringWithFormat:@"%@ nreverb %@, %@, %@",
                self, input, dur, hfdif];
    }
}

- (NSString *)fTableCSDFromFilterParams
{
    NSString *combTable = [NSString stringWithFormat:@"%@%iCombValues ftgentmp 0, 0, %i, %@ %@",
                           [self operationName], (int)[combGains count], -2, combTimes, combGains];
    NSString *allPassTable = [NSString stringWithFormat:@"%@%iCombValues ftgentmp 0, 0, %i, %@ %@",
                              [self operationName], (int)[allPassGains count], -2, allPassTimes, allPassGains];
    NSString *s = [NSString stringWithFormat:@"%@ %@", combTable, allPassTable];
    return s;
}
@end
