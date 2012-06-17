//
//  CSDLoopingOscillator.h
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDSoundFileTable.h"

// TODO: Add optional params
//ar1 [,ar2] loscil3 xamp, kcps, ifn [, ibas] [, imod1] [, ibeg1] [, iend1] [, imod2] [, ibeg2] [, iend2]

@interface CSDLoopingOscillator : CSDOpcode {
    CSDParam * output1;
    CSDParam * output2;
    CSDParam * amplitude;
    CSDParam * frequency;
    CSDParamConstant * baseFrequency;
    CSDSoundFileTable * soundFileTable;
}

@property (nonatomic, strong) CSDParam * output1;
@property (nonatomic, strong) CSDParam * output2;

-(id) initWithSoundFileTable:(CSDSoundFileTable *) fileTable;

-(id) initWithSoundFileTable:(CSDSoundFileTable *) fileTable
                   Amplitude:(CSDParam *)amp;

-(id) initWithSoundFileTable:(CSDSoundFileTable *) fileTable
                   Amplitude:(CSDParam *)amp
                   Frequency:(CSDParamControl *)freq;
@end
