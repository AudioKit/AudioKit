//
//  CSDLineSegment.m
//  ExampleProject
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

-(id)initWithOutput:(NSString *)aOutput iFirstSegmentStartValue:(CSDParam *)aStart iFirstSegmentDuration:(CSDParam *)aDuration iFirstSegementTargetValue:(CSDParam *)aTarget SegmentArray:(CSDParamArray *)aSegmentArray
{
    self = [super init];
    if (self) {
        output                  = aOutput;
        firstSegmentStartValue  = aStart;
        firstSegmentDuration    = aDuration;
        firstSegmentTargetValue = aTarget;
        segmentArray            = aSegmentArray;
    }
    
    return self;
}

-(id)initWithOutput:(NSString *)aOutput iFirstSegmentStartValue:(CSDParam *)aStart iFirstSegmentDuration:(CSDParam *)aDuration iFirstSegementTargetValue:(CSDParam *)aTarget
{
    self = [super init];
    if (self) {
        output                  = aOutput;
        firstSegmentStartValue  = aStart;
        firstSegmentDuration    = aDuration;
        firstSegmentTargetValue = aTarget;
    }
    
    return self;
}

-(NSString *)convertToCsd
{
    if (segmentArray == nil) {
        return [NSString stringWithFormat:@"%@ linseg %@, %@, %@\n", 
                output, 
                [firstSegmentStartValue parameterString], 
                [firstSegmentDuration parameterString], 
                [firstSegmentTargetValue parameterString]];
    } else {
       /* NSMutableString *s = [NSString stringWithFormat:@", "];
        for (int i = 0; i < [segmentArray count]; i++) {
            [s appendFormat:@"%@,", [segmentArray ob
        }
        return [NSString stringWithFormat:@"%@ line %@, %@, %@", 
                output, firstSegmentStartValue, firstSegmentDuration, firstSegmentTargetValue];*/
        return [NSString stringWithFormat:@"%@ linseg %@, %@, %@, %@\n", 
            output, 
                [firstSegmentStartValue parameterString], 
                [firstSegmentDuration parameterString], 
                [firstSegmentTargetValue parameterString], 
                [segmentArray parameterString]];
    }
}

@end
