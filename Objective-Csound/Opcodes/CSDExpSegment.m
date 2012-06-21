//
//  CSDExpSegment.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDExpSegment.h"

@implementation CSDExpSegment
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

-(NSString *) description {
    return [output parameterString];
}

@end