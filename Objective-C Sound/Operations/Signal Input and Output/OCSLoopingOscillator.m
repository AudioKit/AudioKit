//
//  OCSLoopingOscillator.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLoopingOscillator.h"

@interface OCSLoopingOscillator () {
    OCSParameter *output;
    OCSParameter *leftOutput;
    OCSParameter *rightOutput;
    OCSParameter *amp;
    OCSParameter *freqMultiplier;
    OCSConstant *baseFrequency;
    OCSSoundFileTable *soundFileTable;
}
@end

@implementation OCSLoopingOscillator

@synthesize output, leftOutput, rightOutput;

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
        output = output = [OCSParameter parameterWithString:[self operationName]];
        leftOutput  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"1L"]];
        rightOutput = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self operationName], @"2R"]];
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = [OCSConstant parameterWithInt:1];
    }
    return self;
}

// Csound Prototype: TODO: 
// ar1 (,ar2) loscil3 xamp, kcps, ifn (, ibas, imod1, ibeg1, iend1, imod2, ibeg2, iend2)
- (NSString *)stringForCSD {
    NSString *mono = [NSString stringWithFormat:
                      @"%@ loscil3 %@, %@, %@, %@",
                      output, amp, freqMultiplier, soundFileTable, baseFrequency];
    NSString *stereo = [NSString stringWithFormat:
                        @"%@, %@ loscil3 %@, %@, %@, %@",
                        leftOutput, rightOutput, amp, freqMultiplier, soundFileTable, baseFrequency];
    return [NSString stringWithFormat:
            @"if (ftchnls(%@) == 1) then\n"
            @"    %@\n"
            @"else\n"
            @"    %@\n"
            @"endif\n",
            soundFileTable, mono, stereo];
}
@end
