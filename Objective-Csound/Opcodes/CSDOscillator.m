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


-(id) initWithOutput:(NSString *) out
           Amplitude:(CSDParam *) amp 
              kPitch:(CSDParam *) freq
       FunctionTable:(CSDFunctionTable *) f 
{

    self = [super init];
    if (self) {
        opcode = @"oscil";
        //output = out; 
        output = [NSString stringWithFormat:@"a%@%@", [self class], @"1"];
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
            output, 
            opcode, 
            [xAmplitude parameterString],  
            [kPitch parameterString], 
            [functionTable output]];
}



@end
