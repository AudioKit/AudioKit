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
@synthesize amplitude;
@synthesize frequency;
@synthesize functionTable;
@synthesize phase;


-(id) initWithOutput:(NSString *) out
           Amplitude:(NSString *) amp 
           Frequency:(NSString *) freq
       FunctionTable:(CSDFunctionStatement *) f
   AndOptionalPhases:(NSString *) phs {

    self = [super init];
    if (self) {
        opcode = @"oscil";
        output = out; 
        amplitude = amp;
        frequency = freq;
        functionTable = f;
        phase = phs;
    }
    return self; 
}

-(NSString *) textWithPValue:(int) p; {
    if ( @"p" == amplitude ) { 
        amplitude = [NSString stringWithFormat:@"p%i", p++];
    }
    if ( @"p" == frequency ) { 
        frequency = [NSString stringWithFormat:@"p%i", p++]; 
    }
    return [NSString stringWithFormat:@"%@ %@ %@,  %@,  %i\n",
            output, opcode, amplitude, frequency, [functionTable integerIdentifier]];
    
}


@end
