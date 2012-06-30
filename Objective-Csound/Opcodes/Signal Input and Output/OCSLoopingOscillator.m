//
//  OCSLoopingOscillator.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLoopingOscillator.h"

@interface OCSLoopingOscillator () {
    OCSParam *output1;
    OCSParam *output2;
    OCSParam *amp;
    OCSParam *freqMultiplier;
    OCSParamConstant *baseFrequency;
    OCSSoundFileTable *soundFileTable;
}
@end

@implementation OCSLoopingOscillator

@synthesize output1, output2;

- (id)initWithSoundFileTable:(OCSSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable 
                    frequencyMultiplier:[OCSParamConstant paramWithInt:1]
                              amplitude:[OCSParamConstant paramWithInt:1]];
}

- (id)initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   amplitude:(OCSParam *)amplitude
{
    return [self initWithSoundFileTable:fileTable 
                    frequencyMultiplier:[OCSParamConstant paramWithInt:1]
                              amplitude:amplitude];
}

- (id)initWithSoundFileTable:(OCSSoundFileTable *)fileTable
         frequencyMultiplier:(OCSParamControl *)frequencyMultiplier
                   amplitude:(OCSParam *)amplitude;
{
    self = [super init];
    if (self) {
        output1 = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"1L"]];
        output2 = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"2R"]];
        soundFileTable = fileTable;
        amp = amplitude;
        freqMultiplier = frequencyMultiplier;
        baseFrequency = [OCSParamConstant paramWithInt:1];
    }
    return self;
}


- (NSString *)stringForCSD {
    //ar1 [,ar2] loscil3 xamp, kcps, ifn [, ibas] [, imod1] [, ibeg1] [, iend1] [, imod2] [, ibeg2] [, iend2]
    return [NSString stringWithFormat:
            @"%@ loscil3 %@, %@, %@, %@\n",
            output1, amp, freqMultiplier, soundFileTable, baseFrequency];
}

@end
