//
//  OCSLoopingOscillator.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLoopingOscillator.h"

@interface OCSLoopingOscillator () {
    OCSParameter *amp;
    OCSParameter *freqMultiplier;
    OCSConstant *baseFrequency;
    OCSSoundFileTable *soundFileTable;
    LoopingOscillatorType imod1;
}
@end

@implementation OCSLoopingOscillator

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
    self = [super initWithString:[self operationName]];
    if (self) {
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = ocspi(1);
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
