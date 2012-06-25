//
//  OCSLineSegment.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSLineSegment.h"

@interface OCSLineSegment () {
    OCSParamControl *output;
}
@end

@implementation OCSLineSegment

@synthesize output;
@synthesize firstSegmentStartValue;
@synthesize firstSegmentDuration;
@synthesize firstSegmentTargetValue;
@synthesize segmentArray;

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
        return [NSString stringWithFormat:@"%@ linseg %@, %@, %@\n", 
                output, 
                firstSegmentStartValue, 
                firstSegmentDuration, 
                firstSegmentTargetValue];
    } else {
       /* NSMutableString *s = [NSString stringWithFormat:@", "];
        for (int i = 0; i < [segmentArray count]; i++) {
            [s appendFormat:@"%@,", [segmentArray ob
        }
        return [NSString stringWithFormat:@"%@ line %@, %@, %@", 
                output, firstSegmentStartValue, firstSegmentDuration, firstSegmentTargetValue];*/
        return [NSString stringWithFormat:@"%@ linseg %@, %@, %@, %@\n", 
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
