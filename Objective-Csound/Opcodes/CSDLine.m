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

-(id)initWithIStartingValue:(CSDParam *) aStart
                  iDuration:(CSDParam *) aDuration
               iTargetValue:(CSDParam *) aTarget 
{
    self = [super init];

    if (self) {
        output = [CSDParamControl paramWithString:[self uniqueName]];
        startingValue   = aStart;
        duration        = aDuration;
        targetValue     = aTarget;
    }
    return self; 
}

-(NSString *)convertToCsd 
{
    return [NSString stringWithFormat:@"%@ line %@, %@, %@\n", 
            [output parameterString], [startingValue parameterString], [duration parameterString], [targetValue parameterString]];
}

@end
