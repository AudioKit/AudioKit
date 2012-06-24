//
//  OCSExpSegment.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSExpSegment.h"

@implementation OCSExpSegment
@synthesize output;

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
                       SegmentArray:(OCSParamArray *)aSegmentArray
{
    self = [super init];
    
    if (self) {
        output = [OCSParamControl paramWithString:[self opcodeName]];
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
        segmentArray            = aSegmentArray;
    }
    
    return self;
}

- (id)initWithFirstSegmentStartValue:(OCSParamConstant *) start
               FirstSegmentDuration:(OCSParamConstant *) dur
           FirstSegementTargetValue:(OCSParamConstant *) targ
{
    if (self) {
        output = [OCSParamControl paramWithString:[self opcodeName]];
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
    }
    
    return self;
}

- (NSString *)stringForCSD
{
    if (segmentArray == nil) {
        return [NSString stringWithFormat:@"%@ expseg %@, %@, %@\n", 
                output, 
                firstSegmentStartValue, 
                firstSegmentDuration, 
                firstSegmentTargetValue];
    } else {
        return [NSString stringWithFormat:@"%@ expseg %@, %@, %@, %@\n", 
                output, 
                firstSegmentStartValue, 
                firstSegmentDuration, 
                firstSegmentTargetValue, 
                [segmentArray parameterString]];
    }
}

- (NSString *)description {
    return [output parameterString];
}

@end