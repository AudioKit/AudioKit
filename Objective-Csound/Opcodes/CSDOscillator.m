//
//  Oscillator.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOscillator.h"

@implementation CSDOscillator

@synthesize opcode;
@synthesize output;
@synthesize xAmplitude;
@synthesize kPitch;
@synthesize functionTable;


-(id) initWithAmplitude:(CSDParam *) amp 
                 kPitch:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f 
{

    self = [super init];
    if (self) {
        opcode = @"oscil";
        xAmplitude = amp;
        kPitch = freq;
        functionTable = f;
        //Default output is unique, can override if you want pretty CSD output
        output = [NSString stringWithFormat:@"a%@%p", [self class], self];
    }
    return self; 
}


-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:
            @"%@ %@ %@, %@, %@\n",
            output, 
            opcode, 
            [xAmplitude parameterString],  
            [kPitch parameterString], 
            [functionTable output]];
}



@end
