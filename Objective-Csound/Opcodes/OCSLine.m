//
//  OCSLine.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLine.h"

@interface OCSLine () {
    OCSParamControl *output;
}
@end

@implementation OCSLine

@synthesize output;
@synthesize startingValue;
@synthesize duration;
@synthesize targetValue;

- (id)initWithStartingValue:(OCSParamConstant *) start
                  Duration:(OCSParamConstant *) dur
               TargetValue:(OCSParamConstant *) targ
{
    self = [super init];

    if (self) {
        output = [OCSParamControl paramWithString:[self opcodeName]];
        startingValue   = start;
        duration        = dur;
        targetValue     = targ;
    }
    return self; 
}

- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ line %@, %@, %@\n", 
            output, startingValue, duration, targetValue];
}

- (NSString *)description {
    return [output parameterString];
}

@end
