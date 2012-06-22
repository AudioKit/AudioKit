//
//  OCSLoopingOscillator.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLoopingOscillator.h"

@implementation OCSLoopingOscillator

@synthesize output1, output2;

-(id) initWithSoundFileTable:(OCSSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable 
                              Amplitude:[OCSParamConstant paramWithInt:1]
                              Frequency:[OCSParamConstant paramWithInt:1]];
}

-(id) initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   Amplitude:(OCSParam *)amp 
{
    return [self initWithSoundFileTable:fileTable 
                              Amplitude:amp
                              Frequency:[OCSParamConstant paramWithInt:1]];
}

-(id) initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   Amplitude:(OCSParam *)amp
                   Frequency:(OCSParamControl *)freq
{
    self = [super init];
    if (self) {
        output1 = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self uniqueName], @"1L"]];
        output2 = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self uniqueName], @"2R"]];
        soundFileTable = fileTable;
        amplitude = amp;
        frequency = freq;
        baseFrequency = [OCSParamConstant paramWithInt:1];
    }
    return self;
}


-(NSString *)convertToCsd {
    //ar1 [,ar2] loscil3 xamp, kcps, ifn [, ibas] [, imod1] [, ibeg1] [, iend1] [, imod2] [, ibeg2] [, iend2]
    return [NSString stringWithFormat:
            @"%@ loscil3 %@, %@, %@, %@\n",
            output1, amplitude, frequency, soundFileTable, baseFrequency];
}

@end
