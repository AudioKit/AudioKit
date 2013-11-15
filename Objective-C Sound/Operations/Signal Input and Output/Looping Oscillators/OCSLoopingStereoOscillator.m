//
//  OCSLoopingStereoOscillator.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLoopingStereoOscillator.h"

@interface OCSLoopingStereoOscillator () {
    OCSParameter *amp;
    OCSParameter *freqMultiplier;
    OCSConstant *baseFrequency;
    OCSSoundFileTable *soundFileTable;
    LoopingOscillatorType imod1;
    
    OCSConstant *ibeg1;
    OCSConstant *iend1;
    OCSConstant *ibeg2;
    OCSConstant *iend2;
}
@end

@implementation OCSLoopingStereoOscillator


- (instancetype)initWithSoundFileTable:(OCSSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:ocspi(1)
                              amplitude:ocspi(1)
                                   type:kLoopingOscillatorNormal];
    
}

- (instancetype)initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   amplitude:(OCSParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:ocspi(1)
                              amplitude:amplitude
                                   type:kLoopingOscillatorNormal];
}

- (instancetype)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:frequencyMultiplier
                              amplitude:amplitude
                                   type:kLoopingOscillatorNormal];
}


- (instancetype)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude
                        type:(LoopingOscillatorType)type
{
    self = [super init];
    if (self) {
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = ocspi(1);
        imod1 = type;
    }
    return self;
}

-(void)setLoopPointStart:(int)startingSample
                     end:(int)endingSample
            releaseStart:(int)releaseStartingSample
              releaseEnd:(int)releaseEndingSample
{
    ibeg1 = ocspi(startingSample);
    iend1 = ocspi(endingSample);
    ibeg2 = ocspi(releaseStartingSample);
    iend2 = ocspi(releaseEndingSample);
}

// Csound Prototype:
// ar1 (,ar2) loscil3 xamp, kcps, ifn (, ibas, imod1, ibeg1, iend1, imod2, ibeg2, iend2)
- (NSString *)stringForCSD {
    //TODO: fix ugly conditional hack
    if(ibeg1) {
        return [NSString stringWithFormat:
                @"%@ loscil3 %@, %@, %@, %@, %i, %@, %@, %i, %@, %@",
                self, amp, freqMultiplier, soundFileTable, baseFrequency, imod1, ibeg1, iend1, imod1, ibeg2, iend2];
    }
    return [NSString stringWithFormat:
            @"%@ loscil3 %@, %@, %@, %@, %i",
            self, amp, freqMultiplier, soundFileTable, baseFrequency, imod1];
}

@end
