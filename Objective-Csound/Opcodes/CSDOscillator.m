//
//  Oscillator.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOscillator.h"

@implementation CSDOscillator

@synthesize xAmplitude;
@synthesize kPitch;
@synthesize functionTable;


-(id) initWithAmplitude:(CSDParam *) amp 
                 kPitch:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f 
{

    self = [super initWithType:@"a"];
    if (self) {
        opcode = @"oscil";
        xAmplitude = amp;
        kPitch = freq;
        functionTable = f;
    }
    return self; 
}


-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:
            @"%@ %@ %@, %@, %@\n",
            [output parameterString],
            opcode,
            [xAmplitude parameterString],  
            [kPitch parameterString], 
            [functionTable output]];
}



@end
