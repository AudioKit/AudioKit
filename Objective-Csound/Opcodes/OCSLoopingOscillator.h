//
//  OCSLoopingOscillator.h
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSSoundFileTable.h"


// TODO: Add optional params
//ar1 [,ar2] loscil3 xamp, kcps, ifn [, ibas] [, imod1] [, ibeg1] [, iend1] [, imod2] [, ibeg2] [, iend2]

@interface OCSLoopingOscillator : OCSOpcode {
    OCSParam * output1;
    OCSParam * output2;
    OCSParam * amplitude;
    OCSParam * frequency;
    OCSParamConstant * baseFrequency;
    OCSSoundFileTable * soundFileTable;
}

@property (nonatomic, strong) OCSParam * output1;
@property (nonatomic, strong) OCSParam * output2;

-(id) initWithSoundFileTable:(OCSSoundFileTable *) fileTable;

-(id) initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   Amplitude:(OCSParam *)amp;

-(id) initWithSoundFileTable:(OCSSoundFileTable *) fileTable
                   Amplitude:(OCSParam *)amp
                   Frequency:(OCSParamControl *)freq;
@end
