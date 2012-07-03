//
//  OCSLoopingOscillator.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLoopingOscillator.h"

@interface OCSLoopingOscillator () {
    OCSParameter *output1;
    OCSParameter *output2;
    OCSParameter *amp;
    OCSParameter *freqMultiplier;
    OCSConstant *baseFrequency;
    OCSSoundFileTable *soundFileTable;
}
@end

@implementation OCSLoopingOscillator

@synthesize output1, output2;

- (id)initWithSoundFileTable:(OCSSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable 
                    frequencyMultiplier:[OCSConstant parameterWithInt:1]
                              amplitude:[OCSConstant parameterWithInt:1]];
}

- (id)initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   amplitude:(OCSParameter *)amplitude
{
    return [self initWithSoundFileTable:fileTable 
                    frequencyMultiplier:[OCSConstant parameterWithInt:1]
                              amplitude:amplitude];
}

- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSControl *)frequencyMultiplier
                   amplitude:(OCSParameter *)amplitude;
{
    self = [super init];
    if (self) {
        output1 = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"1L"]];
        output2 = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"2R"]];
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = [OCSConstant parameterWithInt:1];
    }
    return self;
}

/// CSD Representation:
/// ar1 [,ar2] loscil3 xamp, kcps, ifn [, ibas] [, imod1] [, ibeg1] [, iend1] [, imod2] [, ibeg2] [, iend2]
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ loscil3 %@, %@, %@, %@",
            output1, amp, freqMultiplier, soundFileTable, baseFrequency];
}

@end
