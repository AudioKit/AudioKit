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
}
@end

@implementation OCSLoopingStereoOscillator


- (id)initWithSoundFileTable:(OCSSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:[OCSConstant parameterWithInt:1]
                              amplitude:[OCSConstant parameterWithInt:1]
                                   type:kLoopingOscillatorNormal];
    
}

- (id)initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   amplitude:(OCSParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:[OCSConstant parameterWithInt:1]
                              amplitude:amplitude
                                   type:kLoopingOscillatorNormal];
}

- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable
                    frequencyMultiplier:frequencyMultiplier
                              amplitude:amplitude
                                   type:kLoopingOscillatorNormal];
}


- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude
                        type:(LoopingOscillatorType)type
{
    self = [super initWithString:[self operationName]];
    if (self) {
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = [OCSConstant parameterWithInt:1];
        imod1 = type;
    }
    return self;
}

// Csound Prototype:
// ar1 (,ar2) loscil3 xamp, kcps, ifn (, ibas, imod1, ibeg1, iend1, imod2, ibeg2, iend2)
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ loscil3 %@, %@, %@, %@, %i",
            self, amp, freqMultiplier, soundFileTable, baseFrequency, imod1];
}

@end
