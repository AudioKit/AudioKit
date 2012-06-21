//
//  CSDLineSegment.m
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDLineSegment.h"

@implementation CSDLineSegment

@synthesize output;
@synthesize firstSegmentStartValue;
@synthesize firstSegmentDuration;
@synthesize firstSegmentTargetValue;
@synthesize segmentArray;

-(id)initWithFirstSegmentStartValue:(CSDParamConstant *) start
               FirstSegmentDuration:(CSDParamConstant *) dur
           FirstSegementTargetValue:(CSDParamConstant *) targ
                       SegmentArray:(CSDParamArray *)aSegmentArray
{
    self = [super init];

    if (self) {
        output = [CSDParamControl paramWithString:[self uniqueName]];
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
        segmentArray            = aSegmentArray;
    }
    
    return self;
}

-(id)initWithFirstSegmentStartValue:(CSDParamConstant *) start
               FirstSegmentDuration:(CSDParamConstant *) dur
           FirstSegementTargetValue:(CSDParamConstant *) targ
{
    if (self) {
        output = [CSDParamControl paramWithString:[self uniqueName]];
        firstSegmentStartValue  = start;
        firstSegmentDuration    = dur;
        firstSegmentTargetValue = targ;
    }
    
    return self;
}

-(NSString *)convertToCsd
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

-(NSString *) description {
    return [output parameterString];
}

@end
