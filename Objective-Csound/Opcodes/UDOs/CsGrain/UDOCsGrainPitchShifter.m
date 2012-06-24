//
//  UDOPitchShifter.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOCsGrainPitchShifter.h"

@implementation UDOCsGrainPitchShifter

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithInputLeft:(OCSParam *)inL
             InputRight:(OCSParam *)inR
                  Pitch:(OCSParamControl *)pch
                   Fine:(OCSParamControl *)fin 
               Feedback:(OCSParamControl *)fbk
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = inL;
        inputRight  = inR;
        pitch       = pch;
        fine        = fin;
        feedback    = fbk;
    }
    return self; 
}

- (NSString *) file {
    return [[NSBundle mainBundle] pathForResource: @"CsGrainPitchShifter" ofType: @"udo"];
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ PitchShifter %@, %@, %@, %@, %@\n",
            outputLeft, outputRight, inputLeft, inputRight, pitch, fine, feedback];
}

@end
