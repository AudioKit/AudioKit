//
//  CSDOscillator.m
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOscillator.h"

@implementation CSDOscillator 

@synthesize output;
@synthesize amplitude;
@synthesize pitch;
@synthesize functionTable;


-(id) initWithAmplitude:(CSDParam *) amp 
                  Pitch:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f 
{
    self = [super init];
    if (self) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        pitch = freq;
        functionTable = f;
    }
    return self; 
}


-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:
            @"%@ oscil %@, %@, %@\n",
            output, amplitude, pitch, 
            [functionTable output]];
}



@end
