//
//  CSDOscillator.m
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOscillator.h"
#import "CSDParamControl.h"

@implementation CSDOscillator 

@synthesize output;
@synthesize amplitude;
@synthesize frequency;
@synthesize functionTable;
@synthesize isControl;


-(id) initWithAmplitude:(CSDParam *) amp 
              Frequency:(CSDParam *) freq
          FunctionTable:(CSDFunctionTable *) f 
            isControlRate:(BOOL)control
{
    self = [super init];
    if (self) {
        isControl = control;
        if (isControl) {
            output = [CSDParamControl paramWithString:[self uniqueName]];
        } else {
            output = [CSDParam paramWithString:[self uniqueName]];
        }

        amplitude = amp;
        frequency = freq;
        functionTable = f;
    }
    return self; 
}

-(id) initWithAmplitude:(CSDParam *)amp 
              Frequency:(CSDParam *)freq 
          FunctionTable:(CSDFunctionTable *)f
{
    self = [super init];
    if (self) {
        output = [CSDParam paramWithString:[self uniqueName]];
        amplitude = amp;
        frequency = freq;
        functionTable = f;
    }
    return self; 
}


-(NSString *)convertToCsd {
    return [NSString stringWithFormat:
            @"%@ oscil %@, %@, %@\n",
            output, amplitude, frequency, functionTable];
}

-(NSString *) description {
    return [output parameterString];
}



@end
