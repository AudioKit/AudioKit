//
//  OCSLine.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLine.h"

@interface OCSLine () {
    OCSParameter *audio;
    OCSControl *control;
    OCSParameter *output;
    
    OCSConstant *start;
    OCSConstant *end;
    OCSConstant *dur;
}
@end

@implementation OCSLine

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initFromValue:(OCSConstant *)startingValue
            toValue:(OCSConstant *)endingValue
           duration:(OCSConstant *)duration
{
    self = [super init];

    if (self) {
        audio   = [OCSParameter parameterWithString:[self opcodeName]];
        control = [OCSControl parameterWithString:[self opcodeName]];
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
