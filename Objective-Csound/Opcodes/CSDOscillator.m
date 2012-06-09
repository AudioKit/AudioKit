//
//  Oscillator.m
//  CsdReinvention
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOscillator.h"

@implementation CSDOscillator 

@synthesize amplitude;
@synthesize pitch;
@synthesize functionTable;


-(id) initWithAmplitude:(CSDParam *) amp 
                  Pitch:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f 
{

    self = [super initWithType:@"a"];
    if (self) {
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
            [output parameterString],
            [amplitude parameterString],  
            [pitch parameterString], 
            [functionTable output]];
}



@end
