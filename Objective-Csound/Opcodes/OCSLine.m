//
//  OCSLine.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLine.h"

@interface OCSLine () {
    OCSParam *audio;
    OCSParamControl *control;
    OCSParam *output;
    
    OCSParamConstant *start;
    OCSParamConstant *end;
    OCSParamConstant *dur;
}
@end

@implementation OCSLine

@synthesize audio;
@synthesize control;
@synthesize output;

- (id)initFromValue:(OCSParamConstant *)startingValue
            ToValue:(OCSParamConstant *)endingValue
           Duration:(OCSParamConstant *)duration
{
    self = [super init];

    if (self) {
        audio   = [OCSParam paramWithString:[self opcodeName]];
        control = [OCSParamControl paramWithString:[self opcodeName]];
        output  =  audio;
        
        start = startingValue;
        end = endingValue;
        dur = duration;
    }
    return self; 
}

- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ line %@, %@, %@\n", output, start, dur, end];
}

- (NSString *)description {
    return [output parameterString];
}

@end
