//
//  OCSLine.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLine.h"

@interface OCSLine () {
    OCSParam *audio;
    OCSControlParam *control;
    OCSParam *output;
    
    OCSConstantParam *start;
    OCSConstantParam *end;
    OCSConstantParam *dur;
}
@end

@implementation OCSLine

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initFromValue:(OCSConstantParam *)startingValue
            toValue:(OCSConstantParam *)endingValue
           duration:(OCSConstantParam *)duration
{
    self = [super init];

    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSControlParam paramWithString:[self opcodeName]];
        output  =  audio;
        
        start = startingValue;
        end = endingValue;
        dur = duration;
    }
    return self; 
}

- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ line %@, %@, %@", output, start, dur, end];
}

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

@end
