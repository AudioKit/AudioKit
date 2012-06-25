//
//  OCSPitchClassToFreq.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPitchClassToFreq.h"

@interface OCSPitchClassToFreq () {
    OCSParam *output;
    OCSParam *input;
}
@end

@implementation OCSPitchClassToFreq
@synthesize output;

-(id)initWithPitch:(OCSParam *)pitch
{
    self = [super init];
    if(self) {
        input = pitch;
        if( [input isKindOfClass:[OCSParamConstant class]]) {
            output = [OCSParamConstant paramWithString:[self opcodeName]];
        } else if( [input isKindOfClass:[OCSParamControl class]]) {
            output = [OCSParamControl paramWithString:[self opcodeName]];
        } else {
            //TODO throw error, control and i-rate only
        }
    }
    return self;
}

-(NSString *)stringForCSD
{
    return [NSString stringWithFormat:@"%@ = cpspch(%@)\n", output, input];
}

@end
