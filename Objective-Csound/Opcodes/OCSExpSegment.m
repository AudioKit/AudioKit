//
//  OCSExpSegment.m
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSExpSegment.h"

@interface OCSExpSegment () {
    OCSParamConstant *start;
    OCSParamConstant *dur;
    OCSParamConstant *target;
    OCSParamArray *segments;
    
    OCSParamControl *output;
}
@end

@implementation OCSExpSegment

@synthesize output;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration
                  DurationValuePairs:(OCSParamArray *)durationValuePairs;
{
    self = [super init];
    
    if (self) {
        output   = [OCSParamControl paramWithString:[self opcodeName]];
        start    = firstSegmentStartValue;
        dur      = firstSegmentDuration;
        target   = firstSegmentTargetValue;
        segments = durationValuePairs;
    }
    
    return self;
}

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *)firstSegmentStartValue
             FirstSegmentTargetValue:(OCSParamConstant *)firstSegmentTargetValue
                FirstSegmentDuration:(OCSParamConstant *)firstSegmentDuration;
{
    return [self initWithFirstSegmentStartValue:firstSegmentStartValue
                        FirstSegmentTargetValue:firstSegmentTargetValue 
                           FirstSegmentDuration:firstSegmentDuration 
                             DurationValuePairs:nil];
}

- (NSString *)stringForCSD
{    
    if (segments == nil) {
        return [NSString stringWithFormat:
                @"%@ expseg %@, %@, %@\n", 
                output, start, dur, target];
    } else {
        return [NSString stringWithFormat:
                @"%@ expseg %@, %@, %@, %@\n", 
                output, start, dur, target, [segments parameterString]];
    }
}

- (NSString *)description {
    return [output parameterString];
}

@end