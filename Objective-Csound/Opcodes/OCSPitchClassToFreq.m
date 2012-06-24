//
//  OCSPitchClassToFreq.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSPitchClassToFreq.h"

@implementation OCSPitchClassToFreq
@synthesize output;

-(id)initWithInput:(OCSParam *)in
{
    self = [super init];
    if(self) {
        input = in;
        if( [input isKindOfClass:[OCSParamConstant class]]) {
            output = [OCSParamConstant paramWithString:[self uniqueName]];
        } else if( [input isKindOfClass:[OCSParamControl class]]) {
            output = [OCSParamControl paramWithString:[self uniqueName]];
        } else {
            //TODO throw error, control and i-rate only
        }
    }
    return self;
}

-(NSString *)convertToCsd
{
    return [NSString stringWithFormat:@"%@ = cpspch(%@)\n", output, input];
}

@end
