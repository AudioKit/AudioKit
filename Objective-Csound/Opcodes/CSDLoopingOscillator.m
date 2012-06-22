//
//  CSDLoopingOscillator.m
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDLoopingOscillator.h"

@implementation CSDLoopingOscillator

@synthesize output1, output2;

-(id) initWithSoundFileTable:(CSDSoundFileTable *) fileTable {
    return [self initWithSoundFileTable:fileTable 
                              Amplitude:[CSDParamConstant paramWithInt:1]
                              Frequency:[CSDParamConstant paramWithInt:1]];
}

-(id) initWithSoundFileTable:(CSDSoundFileTable *) fileTable
                   Amplitude:(CSDParam *)amp 
{
    return [self initWithSoundFileTable:fileTable 
                              Amplitude:amp
                              Frequency:[CSDParamConstant paramWithInt:1]];
}

-(id) initWithSoundFileTable:(CSDSoundFileTable *) fileTable
                   Amplitude:(CSDParam *)amp
                   Frequency:(CSDParamControl *)freq
{
    self = [super init];
    if (self) {
        output1 = [CSDParam paramWithString:[NSString stringWithFormat:@"%@%@",[self uniqueName], @"1L"]];
        output2 = [CSDParam paramWithString:[NSString stringWithFormat:@"%@%@",[self uniqueName], @"2R"]];
        soundFileTable = fileTable;
        amplitude = amp;
        frequency = freq;
        baseFrequency = [CSDParamConstant paramWithInt:1];
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
