//
//  CSDLine.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDLine.h"

@implementation CSDLine

@synthesize output;
@synthesize startingValue;
@synthesize duration;
@synthesize targetValue;

-(id)initWithStartingValue:(CSDParamConstant *) start
                  Duration:(CSDParamConstant *) dur
               TargetValue:(CSDParamConstant *) targ
{
    self = [super init];

    if (self) {
        output = [CSDParamControl paramWithString:[self uniqueName]];
        startingValue   = start;
        duration        = dur;
        targetValue     = targ;
    }
    return self; 
}

-(NSString *)convertToCsd 
{
    return [NSString stringWithFormat:@"%@ line %@, %@, %@\n", 
            output, startingValue, duration, targetValue];
}

-(NSString *) description {
    return [output parameterString];
}

@end
