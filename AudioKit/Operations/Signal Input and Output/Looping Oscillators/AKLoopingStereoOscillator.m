//
//  AKLoopingStereoOscillator.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKLoopingStereoOscillator.h"

@implementation AKLoopingStereoOscillator
{
    AKParameter *amp;
    AKParameter *freqMultiplier;
    AKConstant *baseFrequency;
    AKSoundFileTable *soundFileTable;
    AKLoopingOscillatorType imod1;
    
    AKConstant *ibeg1;
    AKConstant *iend1;
    AKConstant *ibeg2;
    AKConstant *iend2;
}

- (instancetype)initWithSoundFileTable:(AKSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:akpi(1)
                              amplitude:akpi(1)
                                   type:AKLoopingOscillatorTypeNormal];
    
}

- (instancetype)initWithSoundFileTable:(AKSoundFileTable *) fileTable
                             amplitude:(AKParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:akpi(1)
                              amplitude:amplitude
                                   type:AKLoopingOscillatorTypeNormal];
}

- (instancetype)initWithSoundFileTable:(AKSoundFileTable *)fileTable
                   frequencyMultiplier:(AKControl *)frequencyMultiplier
                             amplitude:(AKParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:frequencyMultiplier
                              amplitude:amplitude
                                   type:AKLoopingOscillatorTypeNormal];
}


- (instancetype)initWithSoundFileTable:(AKSoundFileTable *)fileTable
                   frequencyMultiplier:(AKControl *)frequencyMultiplier
                             amplitude:(AKParameter *)amplitude
                                  type:(AKLoopingOscillatorType)type
{
    self = [super initWithString:[self operationName]];
    if (self) {
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = akpi(1);
        imod1 = type;
    }
    return self;
}

-(void)setLoopPointStart:(int)startingSample
                     end:(int)endingSample
            releaseStart:(int)releaseStartingSample
              releaseEnd:(int)releaseEndingSample
{
    ibeg1 = akpi(startingSample);
    iend1 = akpi(endingSample);
    ibeg2 = akpi(releaseStartingSample);
    iend2 = akpi(releaseEndingSample);
}

// Csound Prototype:
// ar1 (,ar2) loscil3 xamp, kcps, ifn (, ibas, imod1, ibeg1, iend1, imod2, ibeg2, iend2)
- (NSString *)stringForCSD {
    if(ibeg1) {
        return [NSString stringWithFormat:
                @"%@ loscil3 %@, %@, %@, %@, %@, %@, %@, %@, %@, %@",
                self, amp, freqMultiplier, soundFileTable, baseFrequency, akpi(imod1), ibeg1, iend1, akpi(imod1), ibeg2, iend2];
    }
    return [NSString stringWithFormat:
            @"%@ loscil3 %@, %@, %@, %@, %@",
            self, amp, freqMultiplier, soundFileTable, baseFrequency, akpi(imod1)];
}

@end
